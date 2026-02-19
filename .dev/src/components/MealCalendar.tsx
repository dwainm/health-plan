import React, { useState, useEffect } from 'react';
import type { MealOption, PlannerState, DayPlan } from '../types/planner';
import { loadPlan, getDaysInMonth, PLANNER_STORAGE_KEY } from '../types/planner';

export default function MealCalendar() {
  const [plan, setPlan] = useState<PlannerState | null>(null);
  const [selectedDay, setSelectedDay] = useState<number | null>(null);

  useEffect(() => {
    const saved = loadPlan();
    if (saved) {
      setPlan(saved);
    }
  }, []);

  if (!plan) {
    return (
      <div className="calendar-container">
        <h2>📅 Meal Calendar</h2>
        <p>No meal plan found.</p>
        <a href="/planner" className="button">Create a Plan</a>
      </div>
    );
  }

  const year = parseInt(plan.currentMonth.split('-')[0]);
  const month = parseInt(plan.currentMonth.split('-')[1]);
  const daysInMonth = getDaysInMonth(year, month);

  // Get first day of month for calendar layout
  const firstDayOfMonth = new Date(year, month - 1, 1).getDay();
  const monthName = new Date(year, month - 1, 1).toLocaleString('default', { month: 'long' });

  const days = [];
  // Empty cells for days before the 1st
  for (let i = 0; i < firstDayOfMonth; i++) {
    days.push(null);
  }
  // Days of the month
  for (let day = 1; day <= daysInMonth; day++) {
    days.push(day);
  }

  const getDayStatus = (day: number): string => {
    const dayPlan = plan.plan[day];
    if (!dayPlan) return 'empty';
    const count = [dayPlan.breakfast, dayPlan.lunch, dayPlan.dinner].filter(Boolean).length;
    if (count === 3) return 'complete';
    if (count > 0) return 'partial';
    return 'empty';
  };

  return (
    <div className="calendar-container">
      <h2>📅 {monthName} {year} Meal Plan</h2>
      
      <div className="calendar-actions">
        <a href="/planner" className="button">
          {plan.isComplete ? 'Edit Plan' : 'Continue Planning'}
        </a>
        <button 
          className="button secondary"
          onClick={() => {
            if (confirm('Export your meal plan to JSON?')) {
              const dataStr = JSON.stringify(plan, null, 2);
              const blob = new Blob([dataStr], { type: 'application/json' });
              const url = URL.createObjectURL(blob);
              const a = document.createElement('a');
              a.href = url;
              a.download = `meal-plan-${plan.currentMonth}.json`;
              a.click();
            }
          }}
        >
          Export Plan
        </button>
      </div>

      <div className="calendar-grid">
        <div className="calendar-header">
          <div>Sun</div>
          <div>Mon</div>
          <div>Tue</div>
          <div>Wed</div>
          <div>Thu</div>
          <div>Fri</div>
          <div>Sat</div>
        </div>
        
        <div className="calendar-days">
          {days.map((day, index) => (
            <div 
              key={index}
              className={`calendar-day ${day ? getDayStatus(day) : 'empty'} ${selectedDay === day ? 'selected' : ''}`}
              onClick={() => day && setSelectedDay(day === selectedDay ? null : day)}
            >
              {day && (
                <>
                  <span className="day-number">{day}</span>
                  <div className="meal-dots">
                    {plan.plan[day]?.breakfast && <span className="dot breakfast">B</span>}
                    {plan.plan[day]?.lunch && <span className="dot lunch">L</span>}
                    {plan.plan[day]?.dinner && <span className="dot dinner">D</span>}
                  </div>
                </>
              )}
            </div>
          ))}
        </div>
      </div>

      <div className="legend">
        <div className="legend-item">
          <span className="dot complete"></span> Complete (3 meals)
        </div>
        <div className="legend-item">
          <span className="dot partial"></span> Partial
        </div>
        <div className="legend-item">
          <span className="dot empty"></span> Empty
        </div>
      </div>

      {selectedDay && plan.plan[selectedDay] && (
        <div className="day-detail">
          <h3>Day {selectedDay}</h3>
          <div className="meal-detail">
            <strong>Breakfast:</strong>
            {plan.plan[selectedDay].breakfast ? (
              <a href={plan.plan[selectedDay].breakfast?.url}>
                {plan.plan[selectedDay].breakfast?.name}
              </a>
            ) : (
              <span className="skipped">Skipped</span>
            )}
          </div>
          <div className="meal-detail">
            <strong>Lunch:</strong>
            {plan.plan[selectedDay].lunch ? (
              <a href={plan.plan[selectedDay].lunch?.url}>
                {plan.plan[selectedDay].lunch?.name}
              </a>
            ) : (
              <span className="skipped">Skipped</span>
            )}
          </div>
          <div className="meal-detail">
            <strong>Dinner:</strong>
            {plan.plan[selectedDay].dinner ? (
              <a href={plan.plan[selectedDay].dinner?.url}>
                {plan.plan[selectedDay].dinner?.name}
              </a>
            ) : (
              <span className="skipped">Skipped</span>
            )}
          </div>
        </div>
      )}

      {!plan.isComplete && (
        <div className="incomplete-notice">
          <p>⚠️ Your plan is incomplete. Days {plan.currentDay}-{daysInMonth} still need meals.</p>
        </div>
      )}
    </div>
  );
}