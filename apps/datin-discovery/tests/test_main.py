import pytest
from fastapi.testclient import TestClient

from datin_discovery.main import app
from datin_discovery.routes.search import SearchQuery


@pytest.fixture
def client() -> TestClient:
    """Create test client."""
    return TestClient(app)


def test_health_check(client: TestClient) -> None:
    """Test health check endpoint."""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}


def test_search(client: TestClient) -> None:
    """Test search endpoint."""
    search_query = SearchQuery(query="test", limit=10)
    response = client.post("/search/", json=search_query.model_dump())
    assert response.status_code == 200
    results = response.json()
    assert len(results) == 2
    assert results[0]["id"] == "1"
    assert results[0]["title"] == "Sample Result 1"
