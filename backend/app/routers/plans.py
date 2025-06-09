# app/routers/plans.py
"""
Router for meal plan endpoints.
"""
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import date

from app import crud, schemas
from app.database import get_db
from app.services.meal_planner import (
    calculate_bmr,
    calculate_tdee,
    adjust_tdee_for_goal,
    plan_daily_meals
)
from app.services.genetic_planner import run_genetic

router = APIRouter()

@router.post("/run", response_model=schemas.MealPlan, status_code=201)
def run_plan(
    plan_in: schemas.MealPlanCreate,
    db: Session = Depends(get_db)
) -> schemas.MealPlan:
    """
    Generate a meal plan using specified method (greedy or genetic),
    save it, and return the created plan.
    """

    # 1. Determine target calories: either from user profile or direct input
    if plan_in.user_id is not None:
        user = crud.get_user(db, plan_in.user_id)
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        # compute BMR → TDEE → adjusted target
        bmr = calculate_bmr(user.weight, user.height, user.age, user.gender)
        tdee = calculate_tdee(bmr, user.activity_level)
        target = adjust_tdee_for_goal(tdee, user.goal)
    else:
        # use the custom target provided
        target = plan_in.target_calories  # guaranteed by schema validator

    # 2. Generate plan meals
    if plan_in.method == 'genetic':
        meals, total_cal = run_genetic(target)
    else:
        # greedy: simply pick random meals until reaching target
        result = plan_daily_meals(target)
        meals = result['meals'][:plan_in.num_meals]
        total_cal = result['total_calories']

    # 3. Save MealPlan
    plan_date = plan_in.date or date.today()
    db_plan = crud.create_meal_plan(
        db,
        plan_date,
        plan_in.user_id if plan_in.user_id is not None else None,
        total_cal
    )

    # 4. Save PlanItems
    for meal in meals:
        crud.add_plan_item(
            db,
            plan_id=db_plan.id,
            meal_id=meal.id,
            serving_size=100.0
        )

    # 5. Load and return full plan
    created = crud.get_plan(db, db_plan.id)
    return created

@router.get("/{plan_id}", response_model=schemas.MealPlan)
def get_plan(
    plan_id: int,
    db: Session = Depends(get_db)
) -> schemas.MealPlan:
    """Retrieve a saved meal plan by ID."""
    plan = crud.get_plan(db, plan_id)
    if not plan:
        raise HTTPException(status_code=404, detail="Plan not found")
    return plan
