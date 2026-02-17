# CI/CD Pipeline Guide

## Overview

The Datin monorepo includes a comprehensive GitHub Actions CI/CD pipeline that automatically runs when code is pushed to the `main` or `develop` branches.

## Pipeline Architecture

### What Gets Triggered

✅ Automatic on:
- Push to `main` branch
- Push to `develop` branch
- Pull requests to `main` or `develop`

### Jobs (Run in Parallel)

```
lint (Node + Python)
├── ESLint for Next.js
├── TypeScript type checking
└── Ruff for Python

build-web (Node)
└── Next.js build

build-api-docker (Docker)
└── Build & push datin-api image

build-discovery-docker (Docker)
└── Build & push datin-discovery image

test-api (Python)
└── pytest with coverage

test-discovery (Python)
└── pytest with coverage

docker-compose-test (Docker)
└── Integration tests with Docker Compose

all-checks (Summary)
└── Waits for all jobs, passes only if all succeed
```

## Key Fixes Applied

### 1. Docker Build Context
**Problem:** Docker builds were failing because the Dockerfile paths didn't match the context
```yaml
# ❌ Before
context: ./apps/datin-api

# ✅ After
context: .
file: ./apps/datin-api/Dockerfile
```

**Why:** The Dockerfiles use paths like `COPY apps/datin-api/...` which only work from the repository root.

### 2. Python App Scripts
**Problem:** Turborepo couldn't run `npm run lint` for Python apps (no package.json)

**Solution:** Added `package.json` files to `datin-api` and `datin-discovery` with npm wrapper scripts:
```json
{
  "scripts": {
    "dev": "uvicorn datin_api.main:app --reload --port 8000",
    "build": "echo 'Build step'",
    "test": "pytest --cov=datin_api --cov-report=xml",
    "lint": "ruff check .",
    "format": "ruff check . --fix && black ."
  }
}
```

This allows Turborepo to manage all apps uniformly.

### 3. Turborepo Configuration
**Updated `turbo.json`:**
```json
{
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".next/**", "build/**"]
    },
    "test": {
      "dependsOn": ["^build"],
      "outputs": ["coverage/**"]
    },
    "lint": {
      "cache": false
    },
    "format": {
      "cache": false
    }
  }
}
```

- `build` depends on dependencies being built first
- `test` depends on `build` completing
- `lint` and `format` don't use cache (they modify files)

## Task Dependencies

```
dev (no deps)
  └─ Runs all services in development mode

build (depends on ^build)
  └─ datin-web builds after its dependencies (if any)
  └─ datin-api builds independently
  └─ datin-discovery builds independently

test (depends on ^build)
  └─ Only runs after build completes
  └─ Tests each service independently

lint (no deps, no cache)
  └─ Runs independently, always fresh

format (no deps, no cache)
  └─ Runs independently, always fresh
```

## Code Quality Standards

### TypeScript/JavaScript (datin-web)
- **Linter:** ESLint + Next.js recommended rules
- **Type Checker:** TypeScript strict mode
- **Formatter:** Prettier
- **Output:** `src/**/*.{js,jsx,ts,tsx}`

### Python (datin-api, datin-discovery)
- **Linter:** Ruff (modern, fast Python linter)
- **Formatter:** Black (opinionated code formatter)
- **Type Checker:** MyPy (static type checking)
- **Config:** Line length 100, strict mode

### Testing
- **Next.js:** Jest with React Testing Library
- **Python:** pytest with coverage reporting
- **Coverage:** Uploaded to Codecov automatically

## Docker Images

### Image Names
```
ghcr.io/DummyDatin/datin-app/datin-api:main
ghcr.io/DummyDatin/datin-app/datin-discovery:main
ghcr.io/DummyDatin/datin-app/datin-web:main
```

### Image Tags
- `main` - Latest from main branch
- `develop` - Latest from develop branch
- `<commit-sha>` - Short commit SHA
- `<git-tag>` - Semantic version tags (if applicable)

### Registry
- **GitHub Container Registry (ghcr.io)**
- **Authentication:** Automatic via `GITHUB_TOKEN`
- **Push:** Only on main/develop branches
- **Access:** Public (adjust org settings if needed)

## Running Locally

### Simulate CI Pipeline Locally

```bash
# Install dependencies
npm install

# Run linting (all apps)
npm run lint

# Run tests (all apps)
npm run test

# Run formatting
npm run format

# Build all apps
npm run build

# Run services locally
npm run dev

# Or use Docker Compose
docker-compose up
```

### Individual App Commands

```bash
# datin-web
cd apps/datin-web
npm run dev        # Start dev server
npm run build      # Production build
npm run test       # Run tests

# datin-api
cd apps/datin-api
npm run dev        # Start server (reload on changes)
npm run test       # Run tests with coverage

# datin-discovery
cd apps/datin-discovery
npm run dev        # Start server (reload on changes)
npm run test       # Run tests with coverage
```

## Troubleshooting

### CI Pipeline Failures

**Docker Build Failed**
- Check if Dockerfile has correct paths (should be `COPY apps/...`)
- Verify context is `.` (root directory)
- Ensure `file:` parameter points to correct Dockerfile

**Lint/Format Failures**
- Run locally: `npm run lint` and `npm run format`
- Check the specific error message in GitHub Actions logs
- Fix issues and push again

**Test Failures**
- Check test coverage: `npm run test`
- View detailed test output in GitHub Actions
- Python tests: `cd apps/datin-api && pytest`

**Docker Compose Test Failed**
- Ensure services start cleanly: `docker-compose up`
- Check if ports are already in use: `lsof -i :3000`
- View logs: `docker-compose logs <service>`

### Accessing Logs

1. Go to repository: https://github.com/DummyDatin/datin-app
2. Click "Actions" tab
3. Select failed workflow run
4. Click job to expand details
5. View step-by-step output

## Deployment Options

### Docker Images

Once images are built and pushed to ghcr.io, deploy to:

**AWS ECS/Fargate:**
```bash
docker pull ghcr.io/DummyDatin/datin-app/datin-api:main
docker tag ... <your-ecr-repo>/datin-api:latest
docker push <your-ecr-repo>/datin-api:latest
# Then update ECS task definitions
```

**AWS EKS (Kubernetes):**
```bash
docker pull ghcr.io/DummyDatin/datin-app/datin-api:main
docker tag ... <your-ecr-repo>/datin-api:latest
docker push <your-ecr-repo>/datin-api:latest
# Then apply Kubernetes manifests
```

**Manual Docker Run:**
```bash
docker pull ghcr.io/DummyDatin/datin-app/datin-api:main
docker run -p 8000:8000 ghcr.io/DummyDatin/datin-app/datin-api:main
```

## Security Notes

- GitHub Container Registry uses `GITHUB_TOKEN` automatically (no secrets needed)
- For private registries: Add secrets like `REGISTRY_USERNAME`, `REGISTRY_PASSWORD`
- Images are public (adjust in GitHub org settings if needed)
- No hardcoded credentials in repository

## Monitoring

### GitHub Actions Dashboard
- https://github.com/DummyDatin/datin-app/actions

### Docker Image Registry
- https://github.com/orgs/DummyDatin/packages

### Badges (Optional)
Add to README.md:
```markdown
![CI Pipeline](https://github.com/DummyDatin/datin-app/actions/workflows/ci.yml/badge.svg)
```

## Common Tasks

### Update Python Dependencies
1. Edit `apps/datin-api/pyproject.toml` or `apps/datin-discovery/pyproject.toml`
2. Push to branch
3. CI pipeline tests new dependencies automatically

### Update Node Dependencies
1. Edit `package.json` in app directory
2. Push to branch
3. CI pipeline tests new dependencies automatically

### Add New Test
1. Create test file in `tests/` or `__tests__/`
2. Push to branch
3. CI pipeline runs tests automatically

### Change Linting Rules
1. Edit `.eslintrc.json` (Next.js)
2. Edit `pyproject.toml` `[tool.ruff]` (Python)
3. Push to branch
4. CI pipeline checks with new rules

## Best Practices

✅ Do:
- Write tests for new features
- Run `npm run lint` before pushing
- Keep commits atomic and well-documented
- Use pull requests for code review
- Check CI pipeline status before merging

❌ Don't:
- Skip failing tests
- Push code with lint errors
- Commit without running linter
- Force push to main (after code review)
- Ignore CI failures

## Getting Help

- Check GitHub Actions logs for specific errors
- Run locally with `npm run lint`, `npm run test`, `npm run dev`
- Review Dockerfile for Docker build issues
- Check `pyproject.toml` and `package.json` for dependency issues
- See main README.md for general setup help
