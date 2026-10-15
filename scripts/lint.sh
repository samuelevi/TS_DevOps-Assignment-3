#!/usr/bin/env bash
set -u

PASS=0
FAIL=0
EXIT_CODE=0

pass() { echo "LINT PASS: $1"; PASS=$((PASS+1)); }
fail() { echo "LINT FAIL: $1"; FAIL=$((FAIL+1)); EXIT_CODE=1; }

echo "=== Lint Check ==="

for f in app/app.sh scripts/lint.sh scripts/build.sh tests/test.sh; do
    if [[ -f "$f" ]]; then
        pass "File exists: $f"
        bash -n "$f" >/dev/null 2>&1 && pass "Syntax OK: $f" || fail "Syntax error: $f"
    else
        fail "Missing file: $f"
    fi
done

if command -v shellcheck >/dev/null 2>&1; then
    for f in app/app.sh scripts/lint.sh scripts/build.sh tests/test.sh; do
        if [[ -f "$f" ]]; then
            if shellcheck "$f" >/dev/null 2>&1; then
                pass "ShellCheck: $f"
            else
                fail "ShellCheck warnings: $f"
            fi
        fi
    done
fi

echo ""
echo "Lint passed: $PASS"
echo "Lint failed: $FAIL"

exit $EXIT_CODE
