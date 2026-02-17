from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter()


class SearchQuery(BaseModel):
    """Search query model."""

    query: str
    limit: int = 10


class SearchResult(BaseModel):
    """Search result model."""

    id: str
    title: str
    score: float


@router.post("/", response_model=list[SearchResult])
async def search(query: SearchQuery) -> list[SearchResult]:
    """Search for items."""
    return [
        SearchResult(id="1", title="Sample Result 1", score=0.95),
        SearchResult(id="2", title="Sample Result 2", score=0.87),
    ]
