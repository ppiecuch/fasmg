#!/bin/sh
# Top-level entry point for the native macOS/AArch64 fasmg work: runs the
# full test suite, then builds/runs every example under core/examples/arm64/
# with the existing macOS x64 bootstrap fasmg (runs under Rosetta 2).
#
# This does NOT build fasmg itself for arm64 - the self-hosting engine
# hasn't been ported yet (see core/source/macos/arm64/PORTING.md). It
# validates the Mach-O ARM64 support added to core/examples/x86/include/
# format/macho.inc, the AArch64 self-host scaffolding in
# core/source/macos/arm64/, and the Apple M-series instruction-set additions
# in packages/aarch64/iset/.
#
# Both examples pass: 00b_hello_syscall (no imports) and 00_hello (imports
# _write/_exit from libSystem via real LC_DYLD_CHAINED_FIXUPS bind entries -
# arm64 dyld doesn't process the classic indirect-symbol-table mechanism at
# all, see PORTING.md for how that was found and fixed).

set -eu

repo_root=$(cd "$(dirname "$0")" && pwd)
bootstrap_fasmg="$repo_root/core/source/macos/x64/fasmg"
test_dir="$repo_root/core/examples/arm64"
out_dir="$repo_root/build/aarch64-macos"

if [ "$(uname -s)" != "Darwin" ]; then
	echo "build-macos.sh: this only builds/runs macOS Mach-O ARM64 binaries; not running on Darwin." >&2
	exit 1
fi

if [ ! -x "$bootstrap_fasmg" ]; then
	echo "build-macos.sh: bootstrap assembler not found or not executable: $bootstrap_fasmg" >&2
	exit 1
fi

mkdir -p "$out_dir"

pass_count=0
fail_count=0

echo "### AArch64 instruction-set encoding verification ###"
if "$repo_root/core/tests/verify_encodings.sh"; then
	pass_count=$((pass_count + 1))
else
	fail_count=$((fail_count + 1))
fi
echo

echo "### Mach-O ARM64 structural regression tests ###"
if "$repo_root/core/tests/verify_macho_arm64.sh"; then
	pass_count=$((pass_count + 1))
else
	fail_count=$((fail_count + 1))
fi
echo

echo "### Example programs (core/examples/arm64/) ###"
for src in "$test_dir"/*.asm; do
	name=$(basename "$src" .asm)
	bin="$out_dir/$name"

	echo "== $name =="

	if ! "$bootstrap_fasmg" "$src" "$bin" >"$out_dir/$name.assemble.log" 2>&1; then
		echo "FAIL  $name: assembly failed"
		sed 's/^/      /' "$out_dir/$name.assemble.log"
		fail_count=$((fail_count + 1))
		continue
	fi

	actual_arch=$(file -b "$bin")
	case "$actual_arch" in
	*"Mach-O 64-bit executable arm64"*) ;;
	*)
		echo "FAIL  $name: assembled, but not a Mach-O arm64 executable ($actual_arch)"
		fail_count=$((fail_count + 1))
		continue
		;;
	esac

	chmod +x "$bin"
	if ! codesign -s - -f "$bin" >"$out_dir/$name.codesign.log" 2>&1; then
		echo "FAIL  $name: assembled to a valid arm64 Mach-O, but ad-hoc codesign failed"
		sed 's/^/      /' "$out_dir/$name.codesign.log"
		fail_count=$((fail_count + 1))
		continue
	fi

	set +e
	actual_output=$("$bin" 2>&1)
	status=$?
	set -e

	if [ "$status" -eq 0 ]; then
		echo "PASS  $name: ran successfully"
		printf '      output: %s\n' "$actual_output"
		pass_count=$((pass_count + 1))
	else
		echo "FAIL  $name: assembled + signed, but exited $status running it"
		if [ "$status" -eq 137 ]; then
			echo "      (killed by the kernel before our code ran - see PORTING.md)"
		elif [ "$status" -eq 139 ]; then
			echo "      (segfault - see PORTING.md, 'What's blocked')"
		fi
		fail_count=$((fail_count + 1))
	fi
done

echo
echo "$pass_count passed, $fail_count failed."

if [ "$fail_count" -gt 0 ]; then
	exit 1
fi
