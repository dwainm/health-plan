---
title: Meal Planner
description: Plan your monthly meals
---

import MealSelectionWizard from '../../components/MealSelectionWizard';

# 🍽️ Monthly Meal Planner

Create your monthly meal plan by selecting meals for each day. For each meal (breakfast, lunch, dinner), you'll see 10 random options. Pick 0-9 or skip the meal.

<MealSelectionWizard client:load />

## How It Works

1. **Select a month** using the date picker
2. **For each day**, you'll see 10 meal options for breakfast
3. **Pick 0-9** to select a meal, or click **Skip** to skip that meal
4. **Continue** through lunch and dinner selections
5. **View your calendar** when complete to see your full month plan

Your plan is automatically saved to your browser's local storage.