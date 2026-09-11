import os
from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker
from dotenv import load_dotenv

# Load variabel dari file .env
load_dotenv()

# Ganti URL di .env kamu dengan format: postgresql://username:password@localhost:5432/nama_database
SQLALCHEMY_DATABASE_URL = os.getenv("DATABASE_URL")

engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Dependency injection untuk route FastAPI
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()