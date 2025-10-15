from fastapi import FastAPI

app = FastAPI(
    title="AI Dev Sample API",
    description="Minimal FastAPI application for AI-driven development",
    version="0.1.0",
)


@app.get("/")
async def root():
    """Root endpoint."""
    return {"message": "AI Dev Sample API", "status": "running"}


@app.get("/health")
async def health():
    """Health check endpoint."""
    return {"status": "healthy", "service": "ai-dev-sample"}
