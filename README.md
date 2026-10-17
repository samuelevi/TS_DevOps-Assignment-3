## Assignment 3 - CI/CD with GitHub Actions

Bash tool that shows system info, checks hosts and ports. Has a CI pipeline that lints, tests, and builds a Docker image on every push/PR.

## Getting Started

```bash
git clone <repo-url>
cd assignment-3
chmod +x app/app.sh scripts/*.sh tests/*.sh
```

To build with Docker:

```bash
docker build -t devops-tool .
```

You need GitHub Actions enabled on the repo for CI to work.

## How to Use

### Locally

```bash
./app/app.sh help
./app/app.sh system-info
./app/app.sh check-host google.com
./app/app.sh check-port google.com 443
```

### With Docker

```bash
docker run --rm devops-tool help
docker run --rm devops-tool system-info
docker run --rm devops-tool check-host google.com
```

### Commands

- `system-info` - shows hostname, user, OS, kernel, uptime, CPU, and memory
- `check-host <host>` - resolves DNS, pings the host, shows network interfaces
- `check-port <host> <port>` - validates the port number and tests TCP connectivity
- `help` - prints usage info

### Exit codes

- `0` = success
- `1` = runtime error
- `2` = bad input (wrong command, missing args, invalid port, etc)

## CI Pipeline

Workflow is at `.github/workflows/ci.yml`. Triggers on push and pull_request.

Three jobs run in sequence:

1. **validate** - runs `scripts/lint.sh` (file existence + bash syntax + shellcheck)
2. **test** - runs `tests/test.sh` (needs validate to pass first)
3. **docker** - runs `scripts/build.sh` to build the image and do smoke tests (needs test to pass first)

I created a branch with a deliberate syntax error to show the pipeline catching it, then fixed it in a follow-up commit.

## Running Tests

```bash
./tests/test.sh   
./scripts/lint.sh 
./scripts/build.sh
./grade.sh        
```

The test suite covers: help output, system-info output, invalid commands, missing commands, missing arguments, non-numeric ports, and out-of-range ports. 12 test cases.

## Project Structure

```
assignment-3/
├── app/
│   └── app.sh           # the main tool
├── scripts/
│   ├── lint.sh          # linter
│   └── build.sh         # docker build + smoke tests
├── tests/
│   └── test.sh          # test suite
├── .github/workflows/
│   └── ci.yml           # CI pipeline
├── Dockerfile
├── compose.yaml
├── .dockerignore
├── grade.sh
└── README.md
```

## Notes

- Docker needs to be installed and running for the build step
- The app is designed for Linux (Alpine in Docker, Ubuntu in CI)
- Only `app/app.sh` gets copied into the Docker image (see `.dockerignore`)
- TCP port check tries bash `/dev/tcp` first, falls back to `nc`
