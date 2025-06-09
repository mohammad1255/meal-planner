# app/main.py
"""
FastAPI application entrypoint for Meal Planner API.
"""
from fastapi import FastAPI
from app.database import engine
from app.models import Base

# Import routers (implement these in app/routers directory)
from app.routers.users import router as users_router
from app.routers.plans import router as plans_router
from app.routers.meals import router as meals_router
from app.routers import exercises
# Create database tables
Base.metadata.create_all(bind=engine)

# Initialize FastAPI app
app = FastAPI(
    title="Meal Planner API",
    description="API for personalized meal planning using greedy and genetic algorithms",
    version="1.0.0"
)
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # في الإنتاج حدد دومين الواجهة فقط
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(users_router, prefix="/users", tags=["users"])
app.include_router(plans_router, prefix="/plans", tags=["plans"])
app.include_router(meals_router, prefix="/meals", tags=["meals"])
app.include_router(exercises.router, prefix="/exercises", tags=["exercises"])

@app.get("/", summary="API Root")
def read_root():
    """Welcome endpoint"""
    return {"message": "Welcome to the Meal Planner API"}
