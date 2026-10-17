#!/usr/bin/env bash
# builds the docker image and runs a few quick smoke tests
set -u

IMG="devops-tool"

echo "=== Building Docker Image ==="

if ! command -v docker >/dev/null 2>&1; then
    echo "docker not found, please install it" >&2
    exit 1
fi

if docker build -t "$IMG" .; then
    echo "Built image: $IMG"
else
    echo "Build failed!" >&2
    exit 1
fi

echo ""
echo "=== Smoke Tests ==="

echo "-> help command"
if docker run --rm "$IMG" help >/dev/null 2>&1; then
    echo "   PASS"
else
    echo "   FAIL"
    exit 1
fi

echo "-> system-info command"
if docker run --rm "$IMG" system-info >/dev/null 2>&1; then
    echo "   PASS"
else
    echo "   FAIL"
    exit 1
fi

echo "-> invalid command (expect failure)"
if docker run --rm "$IMG" bad-command >/dev/null 2>&1; then
    echo "   FAIL (should have errored)"
    exit 1
else
    echo "   PASS"
fi

echo ""
echo "All smoke tests passed."
