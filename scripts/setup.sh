#!/bin/bash

set -e

echo "🚀 Setting up Datin monorepo..."

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Install Node dependencies
echo -e "${BLUE}📦 Installing Node dependencies...${NC}"
npm install

# Setup Python venvs for API
echo -e "${BLUE}🐍 Setting up datin-api...${NC}"
cd apps/datin-api
pip install -e ".[dev]"
cd ../..

# Setup Python venvs for Discovery
echo -e "${BLUE}🐍 Setting up datin-discovery...${NC}"
cd apps/datin-discovery
pip install -e ".[dev]"
cd ../..

echo -e "${GREEN}✅ Setup complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Run 'npm run dev' to start all services"
echo "2. Or run 'docker-compose up' for containerized development"
echo ""
echo "Services will be available at:"
echo "  - Web: http://localhost:3000"
echo "  - API: http://localhost:8000"
echo "  - Discovery: http://localhost:8001"
