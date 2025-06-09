# app/database.py
"""
Database configuration and session management for FastAPI application.
"""
import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

# Get the database URL from environment, default to SQLite for development
DATABASE_URL = os.getenv('DATABASE_URL', 'sqlite:///./foundation.db')

# Create the SQLAlchemy engine
# For SQLite, ensure check_same_thread=False
connect_args = {}
if DATABASE_URL.startswith('sqlite'):
    connect_args = {"check_same_thread": False}

engine = create_engine(
    DATABASE_URL,
    connect_args=connect_args,
    echo=True  # display SQL queries in the logs
)

# Create a configured "Session" class
SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine
)

# Dependency for FastAPI routes
def get_db():
    """
    Provide a transactional scope around a series of operations.
    Usage in FastAPI endpoints:
        db: Session = Depends(get_db)
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
