# Datin Monorepo

A full-stack monorepo using Turborepo with Next.js frontend and Python FastAPI microservices.

## Repository Structure

```
datin-app/
├── apps/
│   ├── datin-web/          # Next.js web application (port 3000)
│   ├── datin-api/          # Python FastAPI service (port 8000)
│   └── datin-discovery/    # Python FastAPI discovery service (port 8001)
├── .github/
│   └── workflows/
│       └── ci.yml          # GitHub Actions CI/CD pipeline
├── docker-compose.yml      # Local development environment
├── package.json            # Root package configuration
├── turbo.json              # Turborepo configuration
└── README.md              # This file
```

## Services

### datin-web
- **Framework**: Next.js 15
- **Language**: TypeScript
- **Port**: 3000
- **Features**: Server-side rendering, API routes, static generation

### datin-api
- **Framework**: FastAPI
- **Language**: Python 3.11
- **Port**: 8000
- **Features**: REST API, async handlers, CORS support

### datin-discovery
- **Framework**: FastAPI
- **Language**: Python 3.11
- **Port**: 8001
- **Features**: Search and discovery service, async handlers

## Getting Started

### Prerequisites
- Node.js 20+
- Python 3.11+
- Docker & Docker Compose (optional, for containerized development)

### Local Development

#### Without Docker

1. **Install dependencies**:
   ```bash
   npm install
   ```

2. **Setup Python environments**:
   ```bash
   cd apps/datin-api && pip install -e ".[dev]"
   cd ../datin-discovery && pip install -e ".[dev]"
   cd ../..
   ```

3. **Run all services**:
   ```bash
   npm run dev
   ```

   Or run individual services:
   ```bash
   # In separate terminals
   npm run dev --filter=datin-web
   npm run dev --filter=datin-api
   npm run dev --filter=datin-discovery
   ```

#### With Docker Compose

```bash
docker-compose up
```

This will start:
- Next.js web app (http://localhost:3000)
- FastAPI service (http://localhost:8000)
- Discovery service (http://localhost:8001)
- Elasticsearch (http://localhost:9200)

### Building

```bash
npm run build
```

### Testing

```bash
npm run test
```

### Linting

```bash
npm run lint
```

### Formatting

```bash
npm run format
```

## CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/ci.yml`) includes:

- **Lint**: ESLint for Next.js, Ruff for Python
- **Type Checking**: TypeScript, MyPy
- **Build**: Next.js and Docker images
- **Test**: Unit tests with coverage reports
- **Docker**: Build and push images to GitHub Container Registry

### Features:
- No AWS required (uses GitHub Container Registry)
- Docker builds are cached for faster CI/CD
- Images are pushed only on main/develop branches
- Health checks included in Docker images
- Docker Compose test integration

### Running Docker Services Separately on AWS

To run the services separately on AWS:

1. **Push images to your registry**:
   ```bash
   docker push <registry>/datin-api:latest
   docker push <registry>/datin-discovery:latest
   docker push <registry>/datin-web:latest
   ```

2. **Run on AWS (example with ECS)**:
   ```bash
   # datin-api
   aws ecs run-task --cluster datin --task-definition datin-api:1

   # datin-discovery
   aws ecs run-task --cluster datin --task-definition datin-discovery:1

   # datin-web
   aws ecs run-task --cluster datin --task-definition datin-web:1
   ```

   Or use AWS CloudFormation, Terraform, or other IaC tools with the Docker images.

## Development Workflow

### Adding a New Service

1. Create a new app directory:
   ```bash
   mkdir apps/new-service
   ```

2. Add `package.json` (for Node/TS) or `pyproject.toml` (for Python)

3. Update `turbo.json` if needed to define build pipeline

4. Update `docker-compose.yml` with the new service

5. Update `.github/workflows/ci.yml` with build/test jobs

### API Communication

- Web app calls API at `http://localhost:8000` (configurable via env)
- Services communicate internally via HTTP

## Environment Variables

Create `.env.local` files in each service:

### datin-web
```
NEXT_PUBLIC_API_URL=http://localhost:8000
```

### datin-api
```
ENV=development
```

### datin-discovery
```
ENV=development
```

## Dependencies

### Root Level
- turbo: Monorepo build system

### datin-web
- next: React framework
- react: UI library
- typescript: Type safety

### datin-api
- fastapi: Web framework
- uvicorn: ASGI server
- pydantic: Data validation

### datin-discovery
- fastapi: Web framework
- uvicorn: ASGI server
- elasticsearch: Search engine client

## License

MIT
