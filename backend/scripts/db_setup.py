# db_setup.py
"""
تعريف قاعدة البيانات وجداولها باستخدام SQLAlchemy (SQLite version)
"""

import os
from sqlalchemy import (
    create_engine, Column, Integer, String, Text, Float,
    ForeignKey, UniqueConstraint
)
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship

# ===============================
# Configuration
# ===============================
# افتراضيًا سيستخدم ملف SQLite في نفس المجلد باسم foundation.db
DB_URL = os.getenv('DATABASE_URL', 'sqlite:///./foundation.db')

# ===============================
# Base and Engine
# ===============================
Base = declarative_base()
# echo=True لتظهر في اللوجي الاستعلامات المنفذة
engine = create_engine(DB_URL, echo=True, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(bind=engine)

# ===============================
# Model Definitions
# ===============================
class FoodCategory(Base):
    __tablename__ = 'food_category'
    id = Column(Integer, primary_key=True, index=True)
    description = Column(Text, nullable=False)

    meals = relationship('Meal', back_populates='category')

class MealNutrientsRaw(Base):
    __tablename__ = 'meal_nutrients_raw'
    fdc_id = Column(Integer, primary_key=True)
    nutrient_id = Column(Integer, primary_key=True)
    amount = Column(Float)
    unit_name = Column(String)

    __table_args__ = (
        UniqueConstraint('fdc_id', 'nutrient_id', name='uix_fdcnutrient'),
    )

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

# ===============================
# Initialization
# ===============================
def init_db():
    """Create all tables in the database."""
    Base.metadata.create_all(bind=engine)

if __name__ == '__main__':
    init_db()
    print("SQLite database and tables created successfully at ./foundation.db")
