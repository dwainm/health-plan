// Meal Plan Types and Data Structures

export interface MealOption {
  id: string;
  name: string;
  category: 'breakfast' | 'lunch' | 'dinner' | 'soup' | 'side' | 'treat';
  calories?: number;
  cookTime?: string;
  url?: string;
}

export interface DayPlan {
  breakfast: MealOption | null;
  lunch: MealOption | null;
  dinner: MealOption | null;
}

export interface MonthPlan {
  [day: number]: DayPlan;
}

export interface PlannerState {
  currentMonth: string; // YYYY-MM format
  currentDay: number;
  plan: MonthPlan;
  isComplete: boolean;
}

// Helper to get all available meals from the content
export function getAvailableMeals(): MealOption[] {
  // This will be populated from Astro content collections
  return [];
}

// Generate 10 random options for a meal type
export function generateMealOptions(
  meals: MealOption[], 
  category: 'breakfast' | 'lunch' | 'dinner',
  count: number = 10
): MealOption[] {
  const filtered = meals.filter(m => m.category === category);
  const shuffled = [...filtered].sort(() => 0.5 - Math.random());
  return shuffled.slice(0, count);
}

// LocalStorage key
export const PLANNER_STORAGE_KEY = 'health-plan-monthly-plan';

// Save plan to localStorage
export function savePlan(plan: PlannerState): void {
  if (typeof window !== 'undefined') {
    localStorage.setItem(PLANNER_STORAGE_KEY, JSON.stringify(plan));
  }
}

// Load plan from localStorage
export function loadPlan(): PlannerState | null {
  if (typeof window !== 'undefined') {
    const saved = localStorage.getItem(PLANNER_STORAGE_KEY);
    if (saved) {
      return JSON.parse(saved);
    }
  }
  return null;
}

// Get days in month
export function getDaysInMonth(year: number, month: number): number {
  return new Date(year, month, 0).getDate();
}

// Initialize empty plan for a month
export function initializeMonthPlan(year: number, month: number): MonthPlan {
  const daysInMonth = getDaysInMonth(year, month);
  const plan: MonthPlan = {};
  
  for (let day = 1; day <= daysInMonth; day++) {
    plan[day] = {
      breakfast: null,
      lunch: null,
      dinner: null
    };
  }
  
  return plan;
}