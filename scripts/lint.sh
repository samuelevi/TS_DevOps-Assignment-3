#!/usr/bin/env bash
# checks that all scripts exist, have valid syntax, and pass shellcheck
set -u

pass_count=0
fail_count=0
exit_code=0

pass() { echo "LINT PASS: $1"; pass_count=$((pass_count + 1)); }
fail() { echo "LINT FAIL: $1"; fail_count=$((fail_count + 1)); exit_code=1; }

echo "=== Lint Check ==="

for f in app/app.sh scripts/lint.sh scripts/build.sh tests/test.sh; do
    if [[ -f "$f" ]]; then
        pass "File exists: $f"
        if bash -n "$f" >/dev/null 2>&1; then
            pass "Syntax OK: $f"
        else
            fail "Syntax error: $f"
        fi
    else
        fail "Missing: $f"
    fi
done


if command -v shellcheck >/dev/null 2>&1; then
    for f in app/app.sh scripts/lint.sh scripts/build.sh tests/test.sh; do
        if [[ -f "$f" ]]; then
            if out=$(shellcheck "$f" 2>&1); then
                pass "ShellCheck: $f"
            else
                fail "ShellCheck issues: $f"
                echo "$out"
            fi
        fi
    done
fi

echo ""
echo "Passed: $pass_count"
echo "Failed: $fail_count"

exit "$exit_code"
