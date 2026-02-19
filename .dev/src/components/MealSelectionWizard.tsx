import React, { useState, useEffect } from 'react';
import type { MealOption, DayPlan, PlannerState } from '../types/planner';
import { 
  savePlan, 
  loadPlan, 
  initializeMonthPlan, 
  getDaysInMonth,
  PLANNER_STORAGE_KEY 
} from '../types/planner';

interface MealSelectionWizardProps {
  meals: MealOption[];
}

type MealType = 'breakfast' | 'lunch' | 'dinner';
type SelectionMode = 'breakfast' | 'lunch' | 'dinner' | 'complete';

export default function MealSelectionWizard({ meals }: MealSelectionWizardProps) {
  const [state, setState] = useState<PlannerState>(() => {
    const saved = loadPlan();
    if (saved) return saved;
    
    const now = new Date();
    return {
      currentMonth: `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`,
      currentDay: 1,
      plan: initializeMonthPlan(now.getFullYear(), now.getMonth() + 1),
      isComplete: false
    };
  });

  const [mode, setMode] = useState<SelectionMode>('breakfast');
  const [options, setOptions] = useState<MealOption[]>([]);
  const [showSkip, setShowSkip] = useState(false);

  const year = parseInt(state.currentMonth.split('-')[0]);
  const month = parseInt(state.currentMonth.split('-')[1]);
  const daysInMonth = getDaysInMonth(year, month);

  // Generate random options when mode changes
  useEffect(() => {
    if (mode !== 'complete') {
      const categoryMeals = meals.filter(m => m.category === mode);
      const shuffled = [...categoryMeals].sort(() => 0.5 - Math.random());
      setOptions(shuffled.slice(0, 10));
      setShowSkip(false);
    }
  }, [mode, meals]);

  // Save state on changes
  useEffect(() => {
    savePlan(state);
  }, [state]);

  const handleSelection = (index: number | null) => {
    const selectedMeal = index !== null ? options[index] : null;
    
    setState(prev => {
      const newPlan = { ...prev.plan };
      newPlan[prev.currentDay] = {
        ...newPlan[prev.currentDay],
        [mode]: selectedMeal
      };
      
      return { ...prev, plan: newPlan };
    });

    // Move to next mode or day
    if (mode === 'breakfast') {
      setMode('lunch');
    } else if (mode === 'lunch') {
      setMode('dinner');
    } else if (mode === 'dinner') {
      if (state.currentDay < daysInMonth) {
        setState(prev => ({ ...prev, currentDay: prev.currentDay + 1 }));
        setMode('breakfast');
      } else {
        setMode('complete');
        setState(prev => ({ ...prev, isComplete: true }));
      }
    }
  };

  const handleSkip = () => {
    handleSelection(null);
  };

  const handleReset = () => {
    if (confirm('Are you sure you want to start over? This will clear your current plan.')) {
      const now = new Date();
      setState({
        currentMonth: `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`,
        currentDay: 1,
        plan: initializeMonthPlan(now.getFullYear(), now.getMonth() + 1),
        isComplete: false
      });
      setMode('breakfast');
    }
  };

  const handleMonthChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const [newYear, newMonth] = e.target.value.split('-').map(Number);
    setState(prev => ({
      ...prev,
      currentMonth: e.target.value,
      currentDay: 1,
      plan: initializeMonthPlan(newYear, newMonth),
      isComplete: false
    }));
    setMode('breakfast');
  };

  if (mode === 'complete') {
    return (
      <div className="wizard-container">
        <h2>🎉 Plan Complete!</h2>
        <p>You've planned all {daysInMonth} days for {state.currentMonth}.</p>
        <div className="actions">
          <a href="/calendar" className="button">View Calendar</a>
          <button onClick={handleReset} className="button secondary">
            Start New Plan
          </button>
        </div>
        
        <div className="summary">
          <h3>Quick Summary</h3>
          {Object.entries(state.plan).slice(0, 7).map(([day, meals]) => (
            <div key={day} className="day-summary">
              <strong>Day {day}:</strong>{' '}
              {meals.breakfast?.name || 'Skip'} /{' '}
              {meals.lunch?.name || 'Skip'} /{' '}
              {meals.dinner?.name || 'Skip'}
            </div>
          ))}
          {daysInMonth > 7 && <p>...and {daysInMonth - 7} more days</p>}
        </div>
      </div>
    );
  }

  return (
    <div className="wizard-container">
      <div className="wizard-header">
        <label>
          Month:
          <input 
            type="month" 
            value={state.currentMonth}
            onChange={handleMonthChange}
          />
        </label>
        <div className="progress">
          Day {state.currentDay} of {daysInMonth}
        </div>
      </div>

      <h2>Day {state.currentDay} - {mode.charAt(0).toUpperCase() + mode.slice(1)}</h2>
      
      <p className="instructions">
        Pick a meal (0-9) or skip this meal:
      </p>

      <div className="meal-options">
        {options.map((meal, index) => (
          <button
            key={meal.id}
            className="meal-option"
            onClick={() => handleSelection(index)}
          >
            <span className="option-number">{index}</span>
            <span className="meal-name">{meal.name}</span>
            {meal.calories && (
              <span className="meal-calories">{meal.calories} cal</span>
            )}
          </button>
        ))}
      </div>

      <div className="skip-section">
        <button 
          className="button skip-button"
          onClick={handleSkip}
        >
          Skip {mode}
        </button>
      </div>

      <div className="current-selection">
        <h3>Current Day Selections:</h3>
        <p>Breakfast: {state.plan[state.currentDay]?.breakfast?.name || 'Not selected'}</p>
        <p>Lunch: {state.plan[state.currentDay]?.lunch?.name || 'Not selected'}</p>
        <p>Dinner: {state.plan[state.currentDay]?.dinner?.name || 'Not selected'}</p>
      </div>

      <button onClick={handleReset} className="button reset-button">
        Reset Plan
      </button>
    </div>
  );
}