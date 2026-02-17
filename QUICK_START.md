# Quick Start Guide

## 🚀 Get Started in 5 Minutes

### Option 1: Local Development (No Docker)

```bash
# 1. Navigate to project
cd datin-app

# 2. Run setup script
bash scripts/setup.sh

# 3. Start all services
npm run dev
```

Open your browser:
- **Web**: http://localhost:3000
- **API Docs**: http://localhost:8000/docs
- **Discovery Docs**: http://localhost:8001/docs

### Option 2: Docker Development (Recommended)

```bash
cd datin-app
docker-compose up
```

Same URLs as above. Includes Elasticsearch on http://localhost:9200

## 📋 Common Commands

```bash
# Install dependencies
make install

# Start development
make dev              # Local services
make docker-up       # Docker containers

# Build for production
make build

# Run tests
make test

# Lint code
make lint

# Stop Docker services
make docker-down

# Clean build artifacts
make clean
```

## 🏗️ Project Structure

- **datin-web** (port 3000): Next.js frontend with TypeScript
- **datin-api** (port 8000): Python FastAPI backend
- **datin-discovery** (port 8001): Python FastAPI search service

## 🧪 Testing

```bash
# All tests
npm run test

# API tests only
cd apps/datin-api && pytest

# Discovery tests only
cd apps/datin-discovery && pytest
```

## 🐳 Docker Images

Built automatically via GitHub Actions:

```bash
# Manual build
docker build -t datin-api:latest ./apps/datin-api
docker build -t datin-discovery:latest ./apps/datin-discovery
docker build -t datin-web:latest ./apps/datin-web

# Run individually
docker run -p 8000:8000 datin-api:latest
docker run -p 8001:8001 datin-discovery:latest
docker run -p 3000:3000 datin-web:latest
```

## 🚢 Deployment

### Docker to AWS

Push to your registry:
```bash
docker push <registry>/datin-api:latest
docker push <registry>/datin-discovery:latest
docker push <registry>/datin-web:latest
```

Then deploy using:
- AWS ECS with task definitions
- AWS Fargate
- EKS with Kubernetes manifests
- CodeDeploy
- Any other container orchestration tool

### Without AWS Docker Support

Use the native services directly:

**datin-api**: Run Python with FastAPI
```bash
pip install -e apps/datin-api
uvicorn datin_api.main:app --host 0.0.0.0 --port 8000
```

**datin-discovery**: Run Python with FastAPI
```bash
pip install -e apps/datin-discovery
uvicorn datin_discovery.main:app --host 0.0.0.0 --port 8001
```

**datin-web**: Run Node.js
```bash
cd apps/datin-web
npm install
npm run build
npm start
```

## 📚 API Examples

### datin-api

```bash
# Health check
curl http://localhost:8000/health

# Hello endpoint
curl http://localhost:8000/api/hello

# Version
curl http://localhost:8000/api/version

# Interactive docs
open http://localhost:8000/docs
```

### datin-discovery

```bash
# Health check
curl http://localhost:8001/health

# Search
curl -X POST http://localhost:8001/search/ \
  -H "Content-Type: application/json" \
  -d '{"query": "test", "limit": 10}'

# Interactive docs
open http://localhost:8001/docs
```

## 🔧 Troubleshooting

### Port conflicts?
```bash
# Find what's using port
lsof -i :3000    # Web
lsof -i :8000    # API
lsof -i :8001    # Discovery
```

### Docker compose not working?
```bash
# Check services
docker-compose ps

# View logs
docker-compose logs api
docker-compose logs discovery
docker-compose logs web
```

### Python venv issues?
```bash
# Manually setup
cd apps/datin-api
python -m venv venv
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate      # Windows
pip install -e ".[dev]"
```

## 📖 Full Documentation

See [README.md](./README.md) for comprehensive documentation.

## 🤝 Contributing

1. Create a branch from `develop`
2. Make your changes
3. Push to GitHub (CI will run automatically)
4. Submit a pull request

All tests must pass before merging!
