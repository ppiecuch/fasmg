#!/bin/sh
# Regression test for the Mach-O ARM64 structural bugs found and fixed while
# bringing up native macOS/AArch64 execution (see core/source/macos/arm64/
# PORTING.md, "Mach-O structural bugs found and fixed" and "The exec-time
# kill: root cause found and fixed"). Each of these was a real bug that
# either crashed the build or got the binary killed by the kernel before any
# of its code ran - this asserts each one explicitly so a future change to
# core/examples/x86/include/format/macho.inc can't silently reintroduce it.
#
# Builds core/examples/arm64/00b_hello_syscall.asm (the zero-import test -
# no dynamic binding involved, so it isolates Mach-O structure/policy issues
# from the separate, still-open chained-fixups bind bug) and checks:
#   - Mach header flags include MH_DYLDLINK + MH_TWOLEVEL + MH_PIE (the
#     actual root cause of the "killed before any code runs" bug)
#   - __PAGEZERO is the standard 4GB, not a shrunken/non-standard size
#   - __TEXT/__DATA/__LINKEDIT maxprot has no W^X violation (no segment
#     grants both write and execute)
#   - __text section is flagged as containing code (S_ATTR_PURE_INSTRUCTIONS
#     + S_ATTR_SOME_INSTRUCTIONS), not flags=0
#   - LC_LOAD_DYLINKER and LC_LOAD_DYLIB are present even though this
#     program imports nothing from either
#   - LC_DYLD_CHAINED_FIXUPS and LC_DYLD_EXPORTS_TRIE are present
#   - the binary actually assembles, ad-hoc signs, and runs to completion
#     with the expected output and exit code - the actual end-to-end
#     regression test for the whole investigation
#
# Also builds core/examples/arm64/00_hello.asm (imports `_write`/`_exit`
# from libSystem.B.dylib) and checks that the real LC_DYLD_CHAINED_FIXUPS
# bind data generated for its imports (see MachO.__nl_symbol_ptr and the
# chained-fixups-data block in macho.inc) is correct - via `otool
# -chained_fixups`, which decodes the bind entries/imports table/segment
# layout human-readably - and that the imported symbols actually resolve
# and the binary runs to completion. This was the "arm64 dyld doesn't
# process the classic indirect-symbol-table mechanism at all" bug: the
# binary used to assemble fine, pass codesign, and then SIGSEGV on a null
# function pointer the moment it tried to call an imported function.
#
# Requires Xcode Command Line Tools (`otool`, `codesign`) and macOS/arm64.

set -eu

repo_root=$(cd "$(dirname "$0")/../.." && pwd)
bootstrap_fasmg="$repo_root/core/source/macos/x64/fasmg"
src="$repo_root/core/examples/arm64/00b_hello_syscall.asm"

if [ "$(uname -s)" != "Darwin" ]; then
	echo "verify_macho_arm64.sh: needs otool/codesign, only runs on macOS." >&2
	exit 1
fi

work_dir=$(mktemp -d)
trap 'rm -rf "$work_dir"' EXIT

bin="$work_dir/00b_hello_syscall"

fail_count=0
pass_count=0

check() {
	description=$1
	if [ "$2" = "$3" ]; then
		echo "PASS  $description"
		pass_count=$((pass_count + 1))
	else
		echo "FAIL  $description (expected '$3', got '$2')"
		fail_count=$((fail_count + 1))
	fi
}

check_contains() {
	description=$1
	haystack=$2
	needle=$3
	case "$haystack" in
	*"$needle"*)
		echo "PASS  $description"
		pass_count=$((pass_count + 1))
		;;
	*)
		echo "FAIL  $description (did not find '$needle')"
		fail_count=$((fail_count + 1))
		;;
	esac
}

"$bootstrap_fasmg" "$src" "$bin" >"$work_dir/assemble.log" 2>&1
if [ ! -f "$bin" ]; then
	echo "FAIL  assembly: $src failed to produce an output file"
	sed 's/^/      /' "$work_dir/assemble.log"
	exit 1
fi

header=$(xcrun otool -hv "$bin")
check_contains "header flags include MH_DYLDLINK" "$header" "DYLDLINK"
check_contains "header flags include MH_TWOLEVEL" "$header" "TWOLEVEL"
check_contains "header flags include MH_PIE" "$header" "PIE"

loadcmds=$(xcrun otool -l "$bin")

pagezero_vmsize=$(echo "$loadcmds" | awk '/segname __PAGEZERO/{found=1} found && /vmsize/{print $2; exit}')
check "__PAGEZERO is the standard 4GB" "$pagezero_vmsize" "0x0000000100000000"

text_maxprot=$(echo "$loadcmds" | awk '/^  segname __TEXT$/{found=1} found && /maxprot/{print $2; exit}')
check "__TEXT maxprot has no write+execute (W^X)" "$text_maxprot" "0x00000005"

data_maxprot=$(echo "$loadcmds" | awk '/^  segname __DATA$/{found=1} found && /maxprot/{print $2; exit}')
check "__DATA maxprot has no write+execute (W^X)" "$data_maxprot" "0x00000003"

linkedit_maxprot=$(echo "$loadcmds" | awk '/segname __LINKEDIT/{found=1} found && /maxprot/{print $2; exit}')
check "__LINKEDIT maxprot has no write+execute (W^X)" "$linkedit_maxprot" "0x00000001"

text_section_flags=$(echo "$loadcmds" | awk '/sectname __text/{found=1} found && /^ +flags/{print $2; exit}')
check "__text section is flagged as code" "$text_section_flags" "0x80000400"

check_contains "LC_LOAD_DYLINKER present" "$loadcmds" "LC_LOAD_DYLINKER"
check_contains "LC_LOAD_DYLIB present" "$loadcmds" "LC_LOAD_DYLIB"
check_contains "LC_DYLD_CHAINED_FIXUPS present" "$loadcmds" "LC_DYLD_CHAINED_FIXUPS"
check_contains "LC_DYLD_EXPORTS_TRIE present" "$loadcmds" "LC_DYLD_EXPORTS_TRIE"

chmod +x "$bin"
if ! codesign -s - "$bin" >"$work_dir/codesign.log" 2>&1; then
	echo "FAIL  ad-hoc codesign"
	sed 's/^/      /' "$work_dir/codesign.log"
	fail_count=$((fail_count + 1))
else
	echo "PASS  ad-hoc codesign"
	pass_count=$((pass_count + 1))
fi

set +e
actual_output=$("$bin" 2>&1)
status=$?
set -e

check "exit code when run" "$status" "0"
check "stdout when run" "$actual_output" "hello via raw darwin syscalls"

echo
echo "--- 00_hello.asm (imports _write/_exit via chained-fixups binds) ---"

src2="$repo_root/core/examples/arm64/00_hello.asm"
bin2="$work_dir/00_hello"

"$bootstrap_fasmg" "$src2" "$bin2" >"$work_dir/assemble2.log" 2>&1
if [ ! -f "$bin2" ]; then
	echo "FAIL  assembly: $src2 failed to produce an output file"
	sed 's/^/      /' "$work_dir/assemble2.log"
	exit 1
fi

fixups=$(xcrun otool -chained_fixups "$bin2")
check_contains "imports_count is 2" "$fixups" "imports_count  = 2"
check_contains "import[0] binds to libSystem" "$fixups" "lib_ordinal = 1 (libSystem)"
check_contains "import[0] resolves the _write symbol name" "$fixups" "(_write)"
check_contains "import[1] resolves the _exit symbol name" "$fixups" "(_exit)"
check_contains "segment_offset is positive (not wrapped negative)" "$fixups" "segment_offset = 0x4000"

chmod +x "$bin2"
if ! codesign -s - "$bin2" >"$work_dir/codesign2.log" 2>&1; then
	echo "FAIL  ad-hoc codesign (00_hello)"
	sed 's/^/      /' "$work_dir/codesign2.log"
	fail_count=$((fail_count + 1))
else
	echo "PASS  ad-hoc codesign (00_hello)"
	pass_count=$((pass_count + 1))
fi

set +e
actual_output2=$("$bin2" 2>&1)
status2=$?
set -e

check "exit code when run (00_hello)" "$status2" "0"
check "stdout when run (00_hello)" "$actual_output2" "hello from native arm64 macos"

echo
echo "$pass_count passed, $fail_count failed."

if [ "$fail_count" -gt 0 ]; then
	exit 1
fi
