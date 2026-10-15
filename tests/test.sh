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
[[ $rc -eq 0 ]] && pass "help returns exit code 0" || fail "help should return exit code 0"
echo "$output" | grep -qi "usage\|command" && pass "help displays usage info" || fail "help should display usage info"

output=$("$APP" system-info 2>&1)
rc=$?
[[ $rc -eq 0 ]] && pass "system-info returns exit code 0" || fail "system-info should return exit code 0"
echo "$output" | grep -qi "hostname" && pass "system-info shows hostname" || fail "system-info should show hostname"

"$APP" invalid-command >/dev/null 2>&1
[[ $? -eq 2 ]] && pass "invalid command returns exit code 2" || fail "invalid command should return exit code 2"

"$APP" >/dev/null 2>&1
[[ $? -eq 2 ]] && pass "missing command returns exit code 2" || fail "missing command should return exit code 2"

"$APP" check-host localhost >/dev/null 2>&1
rc=$?
[[ $rc -eq 0 || $rc -eq 1 ]] && pass "check-host with valid host works" || fail "check-host with valid host should work"

"$APP" check-host >/dev/null 2>&1
[[ $? -eq 2 ]] && pass "check-host with missing host returns exit code 2" || fail "check-host missing host should return exit code 2"

"$APP" check-port localhost abc >/dev/null 2>&1
[[ $? -eq 2 ]] && pass "check-port rejects non-numeric port" || fail "check-port should reject non-numeric port"

"$APP" check-port localhost 0 >/dev/null 2>&1
[[ $? -eq 2 ]] && pass "check-port rejects port 0" || fail "check-port should reject port 0"

"$APP" check-port localhost 65536 >/dev/null 2>&1
[[ $? -eq 2 ]] && pass "check-port rejects port 65536" || fail "check-port should reject port 65536"

"$APP" check-port >/dev/null 2>&1
[[ $? -eq 2 ]] && pass "check-port with missing args returns exit code 2" || fail "check-port missing args should return exit code 2"

echo
echo "======================================"
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo "======================================"

[[ $FAIL -eq 0 ]]
