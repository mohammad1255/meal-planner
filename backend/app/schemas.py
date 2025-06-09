# app/schemas.py
"""
Pydantic schemas for request and response models in Meal Planner API.
"""
from typing import List, Optional, Literal
from datetime import date
from pydantic import BaseModel, model_validator


# ----- Food Category -----
class FoodCategory(BaseModel):
    id: int
    description: str

    class Config:
        from_attributes = True

# ----- Meal -----
class Meal(BaseModel):
    id: int
    fdc_id: int
    description: Optional[str]
    category_id: Optional[int]
    calories_per_100g: Optional[float]
    protein_per_100g: Optional[float]
    fat_per_100g: Optional[float]
    carbs_per_100g: Optional[float]

    class Config:
        from_attributes = True

# ----- User Profile -----
class UserProfileBase(BaseModel):
    name: Optional[str]
    age: int
    gender: Literal['male', 'female']
    height: float
    weight: float
    activity_level: Literal['low', 'light', 'moderate', 'high']
    goal: Literal['lose', 'maintain', 'gain']

class UserProfileCreate(UserProfileBase):
    pass

class UserProfile(UserProfileBase):
    id: int

    class Config:
        from_attributes = True

# ----- Plan Item -----
class PlanItemBase(BaseModel):
    meal_id: int
    serving_size: float  # grams

class PlanItem(PlanItemBase):
    id: int
    meal: Meal

    class Config:
        from_attributes = True

# ----- Meal Plan Create Request -----
class MealPlanCreate(BaseModel):
    # Specify either an existing user to derive target calories or a custom target
    user_id: Optional[int] = None
    target_calories: Optional[float] = None
    date: Optional[date] = None
    method: Literal['genetic', 'greedy']
    num_meals: int

    @model_validator(mode='after')
    def check_one_of(cls, values):
        """Ensure exactly one of user_id or target_calories is provided."""
        uid = values.user_id
        tgt = values.target_calories
        if (uid is None and tgt is None) or (uid is not None and tgt is not None):
            raise ValueError('Specify exactly one of user_id or target_calories')
        return values

# ----- Meal Plan Response -----
class MealPlan(BaseModel):
    id: int
    user_id: Optional[int]
    date: date
    total_calories: float
    items: List[PlanItem]

    class Config:
        from_attributes = True
