#!/usr/bin/env node
/**
 * Generate llms.txt dynamically from content files
 * Run this during build: npm run generate-llms
 */

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const contentDir = path.join(__dirname, '../src/content/docs');
const outputPath = path.join(__dirname, '../public/llms.txt');

function getFiles(dir, prefix = '') {
  const files = [];
  const items = fs.readdirSync(dir);
  
  for (const item of items) {
    const fullPath = path.join(dir, item);
    const stat = fs.statSync(fullPath);
    
    if (stat.isDirectory() && !item.startsWith('.') && item !== 'images') {
      const subFiles = getFiles(fullPath, path.join(prefix, item));
      files.push(...subFiles);
    } else if (stat.isFile() && item.endsWith('.md') && item !== 'README.md') {
      const content = fs.readFileSync(fullPath, 'utf-8');
      const titleMatch = content.match(/^title:\s*(.+)$/m);
      const title = titleMatch ? titleMatch[1].trim() : item.replace('.md', '');
      const slug = path.join(prefix, item.replace('.md', ''));
      files.push({ title, slug, category: prefix.split('/')[0] || 'other' });
    }
  }
  
  return files;
}

function generateLlmsTxt() {
  const allFiles = getFiles(contentDir);
  
  // Group by category
  const categories = {
    meals: allFiles.filter(f => f.category === 'meals'),
    bread: allFiles.filter(f => f.category === 'bread'),
    docs: allFiles.filter(f => f.category === 'docs'),
    planner: allFiles.filter(f => f.category === 'planner'),
    calendar: allFiles.filter(f => f.category === 'calendar'),
    other: allFiles.filter(f => !['meals', 'bread', 'docs', 'planner', 'calendar'].includes(f.category))
  };

  // Further group meals
  const mealCategories = {
    breakfasts: categories.meals.filter(f => f.slug.includes('breakfasts')),
    lunches: categories.meals.filter(f => f.slug.includes('lunches')),
    dinners: categories.meals.filter(f => f.slug.includes('dinners')),
    soups: categories.meals.filter(f => f.slug.includes('soups')),
    sides: categories.meals.filter(f => f.slug.includes('sides')),
    specialmeals: categories.meals.filter(f => f.slug.includes('specialmeals')),
    treats: categories.meals.filter(f => f.slug.includes('treats')),
  };

  let output = `# Health Plan

> A simple, sustainable approach to nutrition and health built around a monthly meal rotation system. The plan emphasizes calorie density, plant-based eating by default, resistance training, whole grains, and grace over perfection. Designed for a family of 6 with automatic, repeatable meals that scale.

## Overview

The Health Plan is built on constraint as freedom. Daily meals are automatic, boring, and effective. Special meals are reserved for guests, celebrations, and occasions. The entire system centers on 30 core recipes (22 meals) that rotate monthly, making meal planning effortless.

Key principles:
- Calorie density over calorie counting
- Plant-based by default (meat as condiment, not centerpiece)  
- Whole grains always (same calories, more filling)
- Resistance training over cardio
- Grace over perfection

## Meal Categories

`;

  // Meals Overview
  const overviewFile = categories.meals.find(f => f.slug.includes('readme') || f.slug.includes('index'));
  if (overviewFile) {
    output += `- [Meals Overview](https://health-plan.dwain-maralack.workers.dev/meals/readme/): Complete meal listing with ${categories.meals.length} recipes across all categories\n`;
  }

  // Breakfasts
  if (mealCategories.breakfasts.length > 0) {
    output += `- [Breakfasts](https://health-plan.dwain-maralack.workers.dev/meals/breakfasts/): ${mealCategories.breakfasts.length} recipes\n`;
  }

  // Lunches
  if (mealCategories.lunches.length > 0) {
    output += `- [Lunches](https://health-plan.dwain-maralack.workers.dev/meals/lunches/): ${mealCategories.lunches.length} recipes\n`;
  }

  // Dinners
  if (mealCategories.dinners.length > 0) {
    output += `- [Dinners](https://health-plan.dwain-maralack.workers.dev/meals/dinners/): ${mealCategories.dinners.length} recipes\n`;
  }

  // Soups
  if (mealCategories.soups.length > 0) {
    output += `- [Soups](https://health-plan.dwain-maralack.workers.dev/meals/soups/): ${mealCategories.soups.length} recipes\n`;
  }

  // Sides
  if (mealCategories.sides.length > 0) {
    output += `- [Sides](https://health-plan.dwain-maralack.workers.dev/meals/sides/): ${mealCategories.sides.length} recipes\n`;
  }

  // Special Meals
  if (mealCategories.specialmeals.length > 0) {
    output += `- [Special Meals](https://health-plan.dwain-maralack.workers.dev/meals/specialmeals/): ${mealCategories.specialmeals.length} recipes\n`;
  }

  // Treats
  if (mealCategories.treats.length > 0) {
    output += `- [Treats](https://health-plan.dwain-maralack.workers.dev/meals/treats/): ${mealCategories.treats.length} recipes\n`;
  }

  output += `\n## Tools

- [Meal Planner](https://health-plan.dwain-maralack.workers.dev/planner/): Interactive meal planning interface
- [Calendar](https://health-plan.dwain-maralack.workers.dev/calendar/): Monthly meal calendar view

## Bread & Baking

`;

  if (categories.bread.length > 0) {
    output += `- [Bread & Baking](https://health-plan.dwain-maralack.workers.dev/bread/): ${categories.bread.length} recipes\n`;
  }

  output += `\n## Optional

- [Core Principles](https://health-plan.dwain-maralack.workers.dev/docs/principles/): Detailed philosophy and approach
- [Techniques](https://health-plan.dwain-maralack.workers.dev/docs/techniques/): Cooking methods and kitchen skills

## All Recipes

`;

  // List all recipes
  const sortedMeals = categories.meals
    .filter(f => !f.slug.includes('readme'))
    .sort((a, b) => a.title.localeCompare(b.title));
  
  for (const meal of sortedMeals) {
    const url = `https://health-plan.dwain-maralack.workers.dev/${meal.slug}`;
    output += `- [${meal.title}](${url})\n`;
  }

  fs.writeFileSync(outputPath, output, 'utf-8');
  console.log(`✓ Generated llms.txt with ${allFiles.length} pages (${categories.meals.length} meals)`);
}

generateLlmsTxt();
