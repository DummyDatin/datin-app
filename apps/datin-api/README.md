# Datin API

Python FastAPI service for the Datin application.

## Development

```bash
pip install -e ".[dev]"
uvicorn datin_api.main:app --reload
```

## Testing

```bash
pytest
```

## Building Docker Image

```bash
docker build -t datin-api:latest .
docker run -p 8000:8000 datin-api:latest
```
