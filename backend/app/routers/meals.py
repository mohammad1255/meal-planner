# app/routers/meals.py
"""
Router for listing meals with optional filters.
"""
from typing import List, Optional
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app import crud, schemas
from app.database import get_db

router = APIRouter()

@router.get("/", response_model=List[schemas.Meal])
def list_meals(
    skip: int = 0,
    limit: int = 100,
    category_id: Optional[int] = None,
    max_calories: Optional[float] = None,
    db: Session = Depends(get_db)
) -> List[schemas.Meal]:
    """
    List meals with pagination, optional category or max_calories filters.
    """
    meals = crud.get_meals(
        db,
        skip=skip,
        limit=limit,
        category_id=category_id,
        max_calories=max_calories
    )
    return meals
