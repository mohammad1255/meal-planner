# meal_planner.py
"""
Module for calculating BMR, TDEE, and generating a simple meal plan
based on the loaded `meal` table in the database.
"""
import random
from sqlalchemy.orm import Session
from db_setup import SessionLocal
from db_setup import Meal

# Activity factors mapping
ACTIVITY_FACTORS = {
    'low': 1.2,
    'light': 1.375,
    'moderate': 1.55,
    'high': 1.725
}

# Goal adjustments
GOAL_ADJUSTMENTS = {
    'lose': -500,
    'maintain': 0,
    'gain': 500
}


def calculate_bmr(weight_kg: float, height_cm: float, age: int, gender: str) -> float:
    """
    Compute Basal Metabolic Rate using Mifflin-St Jeor equation.
    gender: 'male' or 'female'
    """
    if gender.lower() == 'male':
        return 10 * weight_kg + 6.25 * height_cm - 5 * age + 5
    else:
        return 10 * weight_kg + 6.25 * height_cm - 5 * age - 161


def calculate_tdee(bmr: float, activity_level: str) -> float:
    """
    Compute Total Daily Energy Expenditure.
    activity_level: 'low', 'light', 'moderate', 'high'
    """
    factor = ACTIVITY_FACTORS.get(activity_level.lower(), 1.2)
    return bmr * factor


def adjust_tdee_for_goal(tdee: float, goal: str) -> float:
    """
    Adjust TDEE based on user goal.
    goal: 'lose', 'maintain', 'gain'
    Returns target daily calories.
    """
    return tdee + GOAL_ADJUSTMENTS.get(goal.lower(), 0)


def plan_daily_meals(target_calories: float, categories: list = None) -> dict:
    """
    Generate a simple daily meal plan by selecting random
    meals from each category until reaching target calories.
    categories: list of category IDs or None to pick any.
    Returns dict with list of Meal objects and total calories.
    """
    session: Session = SessionLocal()
    try:
        query = session.query(Meal)
        if categories:
            query = query.filter(Meal.category_id.in_(categories))
        meals = query.filter(Meal.calories_per_100g.isnot(None)).all()
        plan = []
        total_cal = 0.0
        # Shuffle and pick until target
        random.shuffle(meals)
        for meal in meals:
            if total_cal >= target_calories:
                break
            plan.append(meal)
            total_cal += meal.calories_per_100g
        return {
            'meals': plan,
            'total_calories': total_cal
        }
    finally:
        session.close()


if __name__ == '__main__':
    # Example usage
    # Suppose user: 70kg, 175cm, 30yrs, male, moderate activity, lose weight
    weight = 70
    height = 175
    age = 30
    gender = 'male'
    activity = 'moderate'
    goal = 'lose'

    bmr = calculate_bmr(weight, height, age, gender)
    tdee = calculate_tdee(bmr, activity)
    target = adjust_tdee_for_goal(tdee, goal)
    plan = plan_daily_meals(target)

    print(f"BMR: {bmr:.2f} kcal")
    print(f"TDEE: {tdee:.2f} kcal")
    print(f"Target Calories: {target:.2f} kcal")
    print("Today's Meal Plan:")
    for m in plan['meals'][:5]:  # show first 5 meals
        print(f"- {m.description}: {m.calories_per_100g} kcal per 100g")
    print(f"Total Calories: {plan['total_calories']:.2f} kcal")
