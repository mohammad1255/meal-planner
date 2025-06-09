# csv_to_db_loader.py
"""
Load CSV data into the database using SQLAlchemy models from db_setup.py.

يتوقع السكريبت أن يكون في نفس المجلد مع ملفات CSV التالية:
 - food_category.csv
 - food_nutrient.csv
 - food.csv
"""

import os
import pandas as pd
from sqlalchemy.orm import Session
from db_setup import engine, SessionLocal, FoodCategory, MealNutrientsRaw, Meal

# دليل CSV هو المجلد الحالي حيث يوجد السكريبت
CSV_DIR = os.path.dirname(os.path.abspath(__file__))

def load_categories(session: Session):
    path = os.path.join(CSV_DIR, 'food_category.csv')
    df = pd.read_csv(path)
    objs = [
        FoodCategory(
            id=int(row['id']),
            description=row['description']
        )
        for _, row in df.iterrows()
    ]
    session.bulk_save_objects(objs)
    print(f"Inserted {len(objs)} categories.")

def load_nutrients_raw(session: Session):
    path = os.path.join(CSV_DIR, 'food_nutrient.csv')
    df = pd.read_csv(path, usecols=['fdc_id', 'nutrient_id', 'amount'])
    objs = [
        MealNutrientsRaw(
            fdc_id=int(row.fdc_id),
            nutrient_id=int(row.nutrient_id),
            amount=float(row.amount),
            unit_name=None
        )
        for _, row in df.iterrows()
    ]
    session.bulk_save_objects(objs)
    print(f"Inserted {len(objs)} nutrient records.")

def load_meals(session: Session):
    # read metadata from food.csv
    food_path = os.path.join(CSV_DIR, 'food.csv')
    df_food = pd.read_csv(food_path, usecols=['fdc_id', 'description', 'food_category_id'])

    # pivot nutrients into columns
    nut_path = os.path.join(CSV_DIR, 'food_nutrient.csv')
    df_n = pd.read_csv(nut_path, usecols=['fdc_id', 'nutrient_id', 'amount'])
    df_piv = df_n.pivot_table(
        index='fdc_id',
        columns='nutrient_id',
        values='amount',
        aggfunc='first'
    ).reset_index()

    # rename nutrient IDs to meaningful columns
    df_piv = df_piv.rename(columns={
        1008: 'calories_per_100g',
        1003: 'protein_per_100g',
        1004: 'fat_per_100g',
        1005: 'carbs_per_100g'
    })

    # merge with food metadata
    df_meal = pd.merge(
        df_food,
        df_piv,
        on='fdc_id',
        how='left'
    ).rename(columns={'food_category_id': 'category_id'})

    # create Meal objects
    objs = []
    for _, row in df_meal.iterrows():
        objs.append(Meal(
            fdc_id=int(row.fdc_id),
            description=row.description,
            category_id=int(row.category_id) if not pd.isna(row.category_id) else None,
            calories_per_100g=row.get('calories_per_100g'),
            protein_per_100g=row.get('protein_per_100g'),
            fat_per_100g=row.get('fat_per_100g'),
            carbs_per_100g=row.get('carbs_per_100g'),
        ))
    session.bulk_save_objects(objs)
    print(f"Inserted {len(objs)} meals.")

def main():
    # ضبط جلسة الاتصال
    SessionLocal.configure(bind=engine)
    with SessionLocal() as session:
        load_categories(session)
        load_nutrients_raw(session)
        load_meals(session)
        session.commit()
        print("Data loaded successfully.")

if __name__ == '__main__':
    main()
