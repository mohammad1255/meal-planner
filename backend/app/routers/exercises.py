from typing import List
from fastapi import APIRouter, Query
import sqlite3
import json

router = APIRouter()
import os

# احصل على المسار الحالي للملف (أيًا كان مكان التشغيل)
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# ارجع لمجلد المشروع الرئيسي (لأن هذا الملف داخل /routers أو /services غالبًا)
ROOT_DIR = os.path.join(BASE_DIR, "..")

# حدّد مسار قاعدة البيانات
DB_PATH = os.path.join(ROOT_DIR, "exercises.db")


def query_exercises(gender: str, goal: str) -> List[dict]:
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    # تحديد العضلات بناءً على الجنس والهدف
    if gender == "female":
        if goal == "lose":
            muscles = ['glutes', 'legs', 'cardio']
        elif goal == "gain":
            muscles = ['glutes', 'quads', 'shoulders']
        else:  # maintain
            muscles = ['legs', 'core']
    elif gender == "male":
        if goal == "lose":
            muscles = ['core', 'legs', 'cardio']
        elif goal == "gain":
            muscles = ['chest', 'arms', 'back']
        else:  # maintain
            muscles = ['chest', 'core']

    # تجهيز الاستعلام
    like_clauses = " OR ".join([f"lower(primary_muscles) LIKE '%{m}%'" for m in muscles])
    query = f"""
        SELECT id, name, category, equipment, level, instructions, image_paths
        FROM exercises
        WHERE {like_clauses}
        LIMIT 10
    """
    cursor.execute(query)
    results = cursor.fetchall()
    conn.close()

    response = []
    for row in results:
        ex_id, name, category, equipment, level, instructions, image_paths_json = row
        image_paths = json.loads(image_paths_json or '[]')
        image_urls = [
            f"https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/{ex_id}/{img}"
            for img in image_paths
        ]
        response.append({
            "id": ex_id,
            "name": name,
            "category": category,
            "equipment": equipment,
            "level": level,
            "instructions": instructions,
            "images": image_urls
        })
    return response


@router.get("/")
def get_exercises(
    gender: str = Query(..., pattern="^(male|female)$"),
    goal: str = Query(..., pattern="^(lose|gain|maintain)$")
):
    print(f"📩 استلام طلب لـ gender={gender}, goal={goal}")
    results = query_exercises(gender, goal)
    print(f"✅ عدد النتائج: {len(results)}")
    return {"results": results}
