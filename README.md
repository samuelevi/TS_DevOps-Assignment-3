# Assignment 3 - CI/CD with GitHub Actions

A Bash diagnostic app with a CI pipeline that lints, tests, and builds a Docker image automatically on every push and pull request. No cloud deployment -- everything runs locally or in GitHub Actions.

## Setup

Clone the repo and make scripts executable:

```bash
git clone <repository-url>
cd assignment-3
chmod +x app/app.sh scripts/*.sh tests/*.sh grade.sh
```

To build the Docker image locally:

```bash
docker build -t devops-tool .
```

You also need a GitHub repo with Actions enabled for the CI pipeline to run.

## Usage

### Running locally

```bash
./app/app.sh help
./app/app.sh system-info
./app/app.sh check-host google.com
./app/app.sh check-port google.com 443
```

### Running with Docker

```bash
docker run --rm devops-tool help
docker run --rm devops-tool system-info
docker run --rm devops-tool check-host google.com
```

**Commands:**
- `system-info` -- hostname, user, OS, kernel, uptime, CPU, memory
- `check-host <host>` -- DNS resolution + ping + network interfaces
- `check-port <host> <port>` -- validates the port and checks TCP connectivity
- `help` -- shows usage

**Exit codes:** `0` for success, `1` for runtime failures, `2` for bad input (unknown command, missing args, invalid port, etc).

## CI Pipeline

The workflow at `.github/workflows/ci.yml` triggers on push and pull_request. It has three jobs that run in order:

1. **validate** -- runs `scripts/lint.sh` (checks files exist, validates bash syntax)
2. **test** -- runs `tests/test.sh` (depends on validate passing)
3. **docker** -- runs `scripts/build.sh` which builds the image and does smoke tests (depends on test passing)

A branch was created with a deliberate syntax error to show the pipeline catching failures, then fixed in a follow-up commit.

## Testing

Run the test suite:

```bash
./tests/test.sh
```

This covers help output, system-info output, invalid/missing commands, missing host argument, non-numeric ports, out-of-range ports, and missing arguments for check-port. 10+ test cases total.

Run the linter:

```bash
./scripts/lint.sh
```

Run the Docker build + smoke tests:

```bash
./scripts/build.sh
```

Run the full grader:

```bash
./grade.sh
```

The grader validates file structure, script permissions, bash syntax, CI workflow configuration (triggers, job dependencies), app behavior with valid and invalid inputs, lint passing, Docker build + smoke tests, and student test suite passing.

## Project Structure

```
assignment-3/
├── app/
│   └── app.sh
├── scripts/
│   ├── lint.sh
│   └── build.sh
├── tests/
│   └── test.sh
├── .github/workflows/
│   └── ci.yml
├── Dockerfile
├── compose.yaml
├── .dockerignore
├── grade.sh
└── README.md
```

## Assumptions

- Docker is installed and running
- GitHub Actions is enabled on the repo
- Designed for Linux (Alpine in Docker, Ubuntu in CI)
- `.dockerignore` excludes tests, scripts, and .github from the image -- only `app/app.sh` gets copied in
- TCP port check uses bash `/dev/tcp` with `nc` as a fallback
- No hardcoded machine-specific values
