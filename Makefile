.PHONY: help setup install dev build test lint clean docker-up docker-down

help:
	@echo "Datin Monorepo - Available commands:"
	@echo ""
	@echo "Setup & Installation:"
	@echo "  make setup          - Install all dependencies"
	@echo "  make install        - Install Node dependencies only"
	@echo ""
	@echo "Development:"
	@echo "  make dev            - Start all services (local)"
	@echo "  make docker-up      - Start all services (Docker)"
	@echo "  make docker-down    - Stop all services (Docker)"
	@echo ""
	@echo "Building & Testing:"
	@echo "  make build          - Build all services"
	@echo "  make test           - Run all tests"
	@echo "  make lint           - Lint all services"
	@echo ""
	@echo "Cleanup:"
	@echo "  make clean          - Remove build artifacts and node_modules"
	@echo ""

setup:
	@bash scripts/setup.sh

install:
	npm install

dev:
	npm run dev

docker-up:
	docker-compose up

docker-down:
	docker-compose down

build:
	npm run build

test:
	npm run test

lint:
	npm run lint

format:
	npm run format

clean:
	rm -rf node_modules
	rm -rf apps/datin-web/.next
	rm -rf apps/datin-web/node_modules
	rm -rf apps/datin-api/__pycache__
	rm -rf apps/datin-api/dist
	rm -rf apps/datin-discovery/__pycache__
	rm -rf apps/datin-discovery/dist
	find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".mypy_cache" -exec rm -rf {} + 2>/dev/null || true
