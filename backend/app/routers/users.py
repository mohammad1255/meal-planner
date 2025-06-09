# app/routers/users.py
"""
Router for user profile endpoints.
"""
from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app import crud, schemas
from app.database import get_db

router = APIRouter()

@router.post("/", response_model=schemas.UserProfile, status_code=201)
def create_user(
    user: schemas.UserProfileCreate,
    db: Session = Depends(get_db)
) -> schemas.UserProfile:
    """Create a new user profile."""
    db_user = crud.create_user(db, user)
    return db_user

@router.get("/", response_model=List[schemas.UserProfile])
def list_users(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
) -> List[schemas.UserProfile]:
    """List user profiles with pagination."""
    users = crud.get_users(db, skip=skip, limit=limit)
    return users

@router.get("/{user_id}", response_model=schemas.UserProfile)
def read_user(
    user_id: int,
    db: Session = Depends(get_db)
) -> schemas.UserProfile:
    """Retrieve a user profile by ID."""
    db_user = crud.get_user(db, user_id)
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return db_user
