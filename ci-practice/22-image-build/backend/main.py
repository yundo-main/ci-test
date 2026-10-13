from fastapi import FastAPI

app = FastAPI(title="CI/CD practice backend")


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}

