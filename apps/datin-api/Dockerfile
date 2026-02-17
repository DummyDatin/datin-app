FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy project files from the apps directory
COPY apps/datin-api/pyproject.toml ./
COPY apps/datin-api/README.md ./
COPY apps/datin-api/datin_api/ ./datin_api/

# Install dependencies
RUN pip install --no-cache-dir -e .

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Run the application
CMD ["uvicorn", "datin_api.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
