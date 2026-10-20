#!/bin/sh
# Cross-checks fasmg's AArch64 instruction encoder (packages/aarch64/iset)
# against Apple's own assembler, instruction by instruction, by assembling
# ref/*.s with `as -arch arm64` and fasmg/*.asm (same instructions, same
# order) with the macOS x64 bootstrap fasmg, then diffing the raw 32-bit
# words. Requires Xcode Command Line Tools (`as`/`otool`) and macOS.
#
# Add new instructions to BOTH ref/<name>.s and fasmg/<name>.asm, in the
# same order, then re-run this script.

set -eu

repo_root=$(cd "$(dirname "$0")/../.." && pwd)
test_dir=$(cd "$(dirname "$0")" && pwd)
bootstrap_fasmg="$repo_root/core/source/macos/x64/fasmg"

if [ "$(uname -s)" != "Darwin" ]; then
	echo "verify_encodings.sh: needs Apple's `as`/`otool`, only runs on macOS." >&2
	exit 1
fi

if [ ! -x "$bootstrap_fasmg" ]; then
	echo "verify_encodings.sh: bootstrap assembler not found: $bootstrap_fasmg" >&2
	exit 1
fi

work_dir=$(mktemp -d)
trap 'rm -rf "$work_dir"' EXIT

pass_count=0
fail_count=0

for ref_src in "$test_dir"/ref/*.s; do
	name=$(basename "$ref_src" .s)
	fasmg_src="$test_dir/fasmg/$name.asm"

	if [ ! -f "$fasmg_src" ]; then
		echo "FAIL  $name: no matching fasmg/$name.asm"
		fail_count=$((fail_count + 1))
		continue
	fi

	xcrun as -arch arm64 -march=armv8.6-a+sha3+sm4+i8mm+bf16 "$ref_src" -o "$work_dir/$name.ref.o"
	xcrun otool -t "$work_dir/$name.ref.o" | tail -n +3 \
		| awk '{for (i = 2; i <= NF; i++) print $i}' >"$work_dir/$name.ref.words"

	"$bootstrap_fasmg" "$fasmg_src" "$work_dir/$name.fasmg.bin" >"$work_dir/$name.assemble.log" 2>&1 || {
		echo "FAIL  $name: fasmg assembly failed"
		sed 's/^/      /' "$work_dir/$name.assemble.log"
		fail_count=$((fail_count + 1))
		continue
	}
	xxd -p -c4 "$work_dir/$name.fasmg.bin" \
		| awk '{print substr($0,7,2) substr($0,5,2) substr($0,3,2) substr($0,1,2)}' >"$work_dir/$name.fasmg.words"

	if diff -q "$work_dir/$name.ref.words" "$work_dir/$name.fasmg.words" >/dev/null; then
		count=$(wc -l <"$work_dir/$name.ref.words" | tr -d ' ')
		echo "PASS  $name: $count/$count words match Apple's assembler"
		pass_count=$((pass_count + 1))
	else
		echo "FAIL  $name: encoding mismatch"
		diff "$work_dir/$name.ref.words" "$work_dir/$name.fasmg.words" | sed 's/^/      /' || true
		fail_count=$((fail_count + 1))
	fi
done

echo
echo "$pass_count passed, $fail_count failed."

if [ "$fail_count" -gt 0 ]; then
	exit 1
fi
