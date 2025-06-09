# app/models.py
"""
SQLAlchemy models for Meal Planner application.
"""
from datetime import date
from sqlalchemy import (
    Column, Integer, String, Text, Float, ForeignKey, Date
)
from sqlalchemy.orm import relationship

from app.database import engine
from sqlalchemy.ext.declarative import declarative_base

# Base declarative class
Base = declarative_base()

class FoodCategory(Base):
    __tablename__ = 'food_category'

    id = Column(Integer, primary_key=True, index=True)
    description = Column(Text, nullable=False)

    meals = relationship('Meal', back_populates='category')

class Meal(Base):
    __tablename__ = 'meal'

    id = Column(Integer, primary_key=True, index=True)
    fdc_id = Column(Integer, unique=True, nullable=False, index=True)
    description = Column(Text)
    category_id = Column(Integer, ForeignKey('food_category.id'))
    calories_per_100g = Column(Float)
    protein_per_100g = Column(Float)
    fat_per_100g = Column(Float)
    carbs_per_100g = Column(Float)

    category = relationship('FoodCategory', back_populates='meals')
    plan_items = relationship('PlanItem', back_populates='meal')

class UserProfile(Base):
    __tablename__ = 'user_profile'

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=True)
    age = Column(Integer, nullable=False)
    gender = Column(String, nullable=False)
    height = Column(Float, nullable=False)
    weight = Column(Float, nullable=False)
    activity_level = Column(String, nullable=False)
    goal = Column(String, nullable=False)

    plans = relationship('MealPlan', back_populates='user')

class MealPlan(Base):
    __tablename__ = 'meal_plan'

    id = Column(Integer, primary_key=True, index=True)
    # Allow user_id to be null for custom-target plans
    user_id = Column(Integer, ForeignKey('user_profile.id'), nullable=True)
    date = Column(Date, default=date.today)
    total_calories = Column(Float)

    user = relationship('UserProfile', back_populates='plans')
    items = relationship('PlanItem', back_populates='plan', cascade='all, delete-orphan')

class PlanItem(Base):
    __tablename__ = 'plan_item'

    id = Column(Integer, primary_key=True, index=True)
    plan_id = Column(Integer, ForeignKey('meal_plan.id'), nullable=False)
    meal_id = Column(Integer, ForeignKey('meal.id'), nullable=False)
    serving_size = Column(Float, default=100.0)  # grams

    plan = relationship('MealPlan', back_populates='items')
    meal = relationship('Meal', back_populates='plan_items')

# Create tables
Base.metadata.create_all(bind=engine)
