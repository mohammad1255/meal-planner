# app/crud.py
"""
CRUD operations for Meal Planner application.
"""
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import date

import app.models as models
import app.schemas as schemas

# ----- UserProfile CRUD -----
def get_user(db: Session, user_id: int) -> Optional[models.UserProfile]:
    return db.query(models.UserProfile).filter(models.UserProfile.id == user_id).first()

def get_users(db: Session, skip: int = 0, limit: int = 100) -> List[models.UserProfile]:
    return db.query(models.UserProfile).offset(skip).limit(limit).all()

def create_user(db: Session, user: schemas.UserProfileCreate) -> models.UserProfile:
    db_user = models.UserProfile(
        name=user.name,
        age=user.age,
        gender=user.gender,
        height=user.height,
        weight=user.weight,
        activity_level=user.activity_level,
        goal=user.goal
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

# ----- MealPlan CRUD -----
def create_meal_plan(
    db: Session,
    plan_date: date,
    user_id: int,
    total_calories: float
) -> models.MealPlan:
    db_plan = models.MealPlan(
        user_id=user_id,
        date=plan_date,
        total_calories=total_calories
    )
    db.add(db_plan)
    db.commit()
    db.refresh(db_plan)
    return db_plan

def add_plan_item(
    db: Session,
    plan_id: int,
    meal_id: int,
    serving_size: float = 100.0
) -> models.PlanItem:
    item = models.PlanItem(
        plan_id=plan_id,
        meal_id=meal_id,
        serving_size=serving_size
    )
    db.add(item)
    db.commit()
    db.refresh(item)
    return item

def get_plan(db: Session, plan_id: int) -> Optional[models.MealPlan]:
    return db.query(models.MealPlan).filter(models.MealPlan.id == plan_id).first()

# ----- Meal Listing CRUD -----
def get_meals(
    db: Session,
    skip: int = 0,
    limit: int = 100,
    category_id: Optional[int] = None,
    max_calories: Optional[float] = None
) -> List[models.Meal]:
    query = db.query(models.Meal)
    if category_id is not None:
        query = query.filter(models.Meal.category_id == category_id)
    if max_calories is not None:
        query = query.filter(models.Meal.calories_per_100g != None)
        query = query.filter(models.Meal.calories_per_100g <= max_calories)
    return query.offset(skip).limit(limit).all()
