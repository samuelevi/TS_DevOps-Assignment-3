#!/usr/bin/env bash
set -u

APP="./app/app.sh"
PASS=0
FAIL=0

pass() { echo "PASS: $1"; PASS=$((PASS+1)); }
fail() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }

echo "======================================"
echo " Assignment 3 - Student Tests"
echo "======================================"
echo

output=$("$APP" help 2>&1)
rc=$?
if [[ $rc -eq 0 ]]; then
    pass "help returns exit code 0"
else
    fail "help should return exit code 0"
fi
if echo "$output" | grep -qi "usage\|command"; then
    pass "help displays usage info"
else
    fail "help should display usage info"
fi

output=$("$APP" system-info 2>&1)
rc=$?
if [[ $rc -eq 0 ]]; then
    pass "system-info returns exit code 0"
else
    fail "system-info should return exit code 0"
fi
if echo "$output" | grep -qi "hostname"; then
    pass "system-info shows hostname"
else
    fail "system-info should show hostname"
fi

"$APP" invalid-command >/dev/null 2>&1
rc=$?
if [[ $rc -eq 2 ]]; then
    pass "invalid command returns exit code 2"
else
    fail "invalid command should return exit code 2"
fi

"$APP" >/dev/null 2>&1
rc=$?
if [[ $rc -eq 2 ]]; then
    pass "missing command returns exit code 2"
else
    fail "missing command should return exit code 2"
fi

"$APP" check-host localhost >/dev/null 2>&1
rc=$?
if [[ $rc -eq 0 || $rc -eq 1 ]]; then
    pass "check-host with valid host works"
else
    fail "check-host with valid host should work"
fi

"$APP" check-host >/dev/null 2>&1
rc=$?
if [[ $rc -eq 2 ]]; then
    pass "check-host with missing host returns exit code 2"
else
    fail "check-host missing host should return exit code 2"
fi

"$APP" check-port localhost abc >/dev/null 2>&1
rc=$?
if [[ $rc -eq 2 ]]; then
    pass "check-port rejects non-numeric port"
else
    fail "check-port should reject non-numeric port"
fi

"$APP" check-port localhost 0 >/dev/null 2>&1
rc=$?
if [[ $rc -eq 2 ]]; then
    pass "check-port rejects port 0"
else
    fail "check-port should reject port 0"
fi

"$APP" check-port localhost 65536 >/dev/null 2>&1
rc=$?
if [[ $rc -eq 2 ]]; then
    pass "check-port rejects port 65536"
else
    fail "check-port should reject port 65536"
fi

"$APP" check-port >/dev/null 2>&1
rc=$?
if [[ $rc -eq 2 ]]; then
    pass "check-port with missing args returns exit code 2"
else
    fail "check-port missing args should return exit code 2"
fi

echo
echo "======================================"
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo "======================================"

[[ $FAIL -eq 0 ]]
