# Datin Discovery

Python FastAPI service for discovery and search in the Datin application.

## Development

```bash
pip install -e ".[dev]"
uvicorn datin_discovery.main:app --reload --port 8001
```

## Testing

```bash
pytest
```

## Building Docker Image

```bash
docker build -t datin-discovery:latest .
docker run -p 8001:8001 datin-discovery:latest
```
