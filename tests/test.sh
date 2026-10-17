#!/usr/bin/env bash
# test suite for the devops tool
set -u

APP="./app/app.sh"
passed=0
failed=0

pass() { echo "PASS: $1"; passed=$((passed + 1)); }
fail() { echo "FAIL: $1"; failed=$((failed + 1)); }

echo "======================================"
echo "  Assignment 3 - Tests"
echo "======================================"
echo

# --- help command ---

output=$("$APP" help 2>&1)
rc=$?
if [[ $rc -eq 0 ]]; then
    pass "help exits with 0"
else
    fail "help should exit 0"
fi

if echo "$output" | grep -qi "usage\|command"; then
    pass "help shows usage info"
else
    fail "help should show usage info"
fi

# --- system-info ---

output=$("$APP" system-info 2>&1)
rc=$?
if [[ $rc -eq 0 ]]; then
    pass "system-info exits with 0"
else
    fail "system-info should exit 0"
fi

if echo "$output" | grep -qi "hostname"; then
    pass "system-info includes hostname"
else
    fail "system-info should show hostname"
fi

# --- error cases ---

"$APP" invalid-command >/dev/null 2>&1
rc=$?
if [[ $rc -eq 2 ]]; then
    pass "bad command returns exit 2"
else
    fail "bad command should return exit 2"
fi

"$APP" >/dev/null 2>&1
rc=$?
if [[ $rc -eq 2 ]]; then
    pass "no args returns exit 2"
else
    fail "no args should return exit 2"
fi

# --- check-host ---

"$APP" check-host localhost >/dev/null 2>&1
rc=$?
if [[ $rc -eq 0 || $rc -eq 1 ]]; then
    pass "check-host localhost runs ok"
else
    fail "check-host localhost should work"
fi

"$APP" check-host >/dev/null 2>&1
rc=$?
if [[ $rc -eq 2 ]]; then
    pass "check-host with no args returns 2"
else
    fail "check-host with no args should return 2"
fi

# --- check-port edge cases ---

"$APP" check-port localhost abc >/dev/null 2>&1
rc=$?
if [[ $rc -eq 2 ]]; then
    pass "rejects non-numeric port"
else
    fail "should reject non-numeric port"
fi

"$APP" check-port localhost 0 >/dev/null 2>&1
rc=$?
if [[ $rc -eq 2 ]]; then
    pass "rejects port 0"
else
    fail "should reject port 0"
fi

"$APP" check-port localhost 65536 >/dev/null 2>&1
rc=$?
if [[ $rc -eq 2 ]]; then
    pass "rejects port 65536"
else
    fail "should reject port 65536"
fi

"$APP" check-port >/dev/null 2>&1
rc=$?
if [[ $rc -eq 2 ]]; then
    pass "check-port no args returns 2"
else
    fail "check-port no args should return 2"
fi

"$APP" check-port localhost >/dev/null 2>&1
rc=$?
if [[ $rc -eq 2 ]]; then
    pass "check-port missing port returns 2"
else
    fail "check-port missing port should return 2"
fi

# --- results ---

echo
echo "======================================"
echo "Passed: $passed  Failed: $failed"
echo "======================================"

[[ $failed -eq 0 ]]
