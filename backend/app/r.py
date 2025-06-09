import sqlite3

conn = sqlite3.connect(r"C:\Users\HP\meal-planner\backend\app\exercises.db")
cur = conn.cursor()
cur.execute("SELECT * FROM exercises;")
print(cur.fetchall())  # لازم يحتوي على جدول اسمه 'exercises'
conn.close()