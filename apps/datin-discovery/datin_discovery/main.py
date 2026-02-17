from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from datin_discovery.routes import health, search

app = FastAPI(
    title="Datin Discovery",
    description="Datin discovery and search service",
    version="1.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(health.router, tags=["health"])
app.include_router(search.router, prefix="/search", tags=["search"])


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)
