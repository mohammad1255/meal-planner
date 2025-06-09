# app/services/genetic_planner.py
"""
Genetic algorithm for generating meal plans that match a target daily calorie goal.
"""
import random
from typing import List, Tuple
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models import Meal

# Genetic Algorithm Parameters
POPULATION_SIZE = 50
GENERATIONS = 100
INDIVIDUAL_SIZE = 5      # number of meals per plan
TOURNAMENT_SIZE = 3
CROSSOVER_RATE = 0.8
MUTATION_RATE = 0.2


def fetch_meals(session: Session) -> List[Meal]:
    """Fetch all meals with known calorie values."""
    return session.query(Meal).filter(Meal.calories_per_100g.isnot(None)).all()


def fitness(individual: List[int], meals: List[Meal], target: float) -> float:
    """Fitness: inverse of absolute difference from target calories."""
    total = sum(meals[i].calories_per_100g for i in individual)
    diff = abs(total - target)
    return 1.0 / (1.0 + diff)


def create_individual(meals: List[Meal]) -> List[int]:
    """Random individual: list of indices into meals list."""
    return [random.randrange(len(meals)) for _ in range(INDIVIDUAL_SIZE)]


def crossover(parent1: List[int], parent2: List[int]) -> Tuple[List[int], List[int]]:
    """One-point crossover."""
    if random.random() > CROSSOVER_RATE:
        return parent1[:], parent2[:]
    point = random.randrange(1, INDIVIDUAL_SIZE)
    child1 = parent1[:point] + parent2[point:]
    child2 = parent2[:point] + parent1[point:]
    return child1, child2


def mutate(individual: List[int], meals: List[Meal]) -> None:
    """Randomly replace a gene with a new meal index."""
    for idx in range(INDIVIDUAL_SIZE):
        if random.random() < MUTATION_RATE:
            individual[idx] = random.randrange(len(meals))


def select(population: List[List[int]], fitnesses: List[float]) -> List[int]:
    """Tournament selection."""
    best = None
    best_fit = -1.0
    for _ in range(TOURNAMENT_SIZE):
        i = random.randrange(len(population))
        if fitnesses[i] > best_fit:
            best_fit = fitnesses[i]
            best = population[i]
    return best[:]


def run_genetic(target_cal: float) -> Tuple[List[Meal], float]:
    """Run GA and return best meal plan and its total calories."""
    session = SessionLocal()
    try:
        meals = fetch_meals(session)
        # Initialize population
        population = [create_individual(meals) for _ in range(POPULATION_SIZE)]
        best_ind, best_fit = None, -1.0

        for gen in range(GENERATIONS):
            # Evaluate fitness
            fits = [fitness(ind, meals, target_cal) for ind in population]
            # Track best
            for ind, fit in zip(population, fits):
                if fit > best_fit:
                    best_fit, best_ind = fit, ind[:]
            # Produce next generation
            new_pop = []
            while len(new_pop) < POPULATION_SIZE:
                p1 = select(population, fits)
                p2 = select(population, fits)
                c1, c2 = crossover(p1, p2)
                mutate(c1, meals)
                mutate(c2, meals)
                new_pop.extend([c1, c2])
            population = new_pop[:POPULATION_SIZE]

        # Build result
        plan_meals = [meals[i] for i in best_ind]
        total_cal = sum(m.calories_per_100g for m in plan_meals)
        return plan_meals, total_cal
    finally:
        session.close()


# Example usage
if __name__ == '__main__':
    target = 2000.0  # target calories
    plan, total = run_genetic(target)
    print(f"Genetic Plan for {target} kcal (total: {total:.1f} kcal):")
    for m in plan:
        print(f"- {m.description}: {m.calories_per_100g} kcal per 100g")
