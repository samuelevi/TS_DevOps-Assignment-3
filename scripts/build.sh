#!/usr/bin/env bash
set -u

IMAGE="devops-tool"

echo "=== Building Docker Image ==="

if ! command -v docker >/dev/null 2>&1; then
    echo "Error: Docker is not installed." >&2
    exit 1
fi

if docker build -t "$IMAGE" . ; then
    echo "Build successful: $IMAGE"
else
    echo "Build failed." >&2
    exit 1
fi

echo ""
echo "=== Running Smoke Tests ==="

echo "Test: help command"
if docker run --rm "$IMAGE" help >/dev/null 2>&1; then
    echo "PASS: help"
else
    echo "FAIL: help"
    exit 1
fi

echo "Test: system-info command"
if docker run --rm "$IMAGE" system-info >/dev/null 2>&1; then
    echo "PASS: system-info"
else
    echo "FAIL: system-info"
    exit 1
fi

echo "Test: invalid command (should fail)"
if docker run --rm "$IMAGE" invalid-command >/dev/null 2>&1; then
    echo "FAIL: invalid command should return non-zero"
    exit 1
else
    echo "PASS: invalid command returns non-zero"
fi

echo ""
echo "All smoke tests passed."
