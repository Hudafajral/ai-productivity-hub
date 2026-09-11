from fastapi import FastAPI
from app.core.database import engine, Base
from app.api.v1 import schedules

# Otomatis membuat tabel di PostgreSQL jika belum ada
Base.metadata.create_all(bind=engine)

app = FastAPI(title="AI Notebook API")

# Daftarkan router
app.include_router(schedules.router, prefix="/api/v1")
@app.get("/")
def root():
    return {"message": "Backend is running!"}