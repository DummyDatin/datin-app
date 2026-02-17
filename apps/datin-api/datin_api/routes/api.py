from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter()


class Message(BaseModel):
    """Message response model."""

    message: str


@router.get("/hello", response_model=Message)
async def hello() -> Message:
    """Hello endpoint."""
    return Message(message="Hello from Datin API!")


@router.get("/version", response_model=dict[str, str])
async def version() -> dict[str, str]:
    """Get API version."""
    return {"version": "1.0.0", "name": "datin-api"}
