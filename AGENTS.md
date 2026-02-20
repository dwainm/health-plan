# Project Structure for AI Agents

## Critical: Two-Layer Source Structure

This project has a **dual source structure** that is easy to confuse:

### 1. Content Source (ROOT LEVEL)
**Location:** `/meals/`, `/bread/`, `/docs/`  
**Purpose:** Source of truth for all content  
**Edit these files when updating recipes, principles, or documentation**

### 2. Site Source (.dev/)
**Location:** `.dev/src/content/docs/`  
**Purpose:** Astro site source code  
**⚠️ DO NOT EDIT THESE FILES DIRECTLY**  

They are auto-generated on build by `scripts/sync-content.js` which copies from root `/meals/`, `/bread/`, `/docs/` into `.dev/src/content/docs/`

## Workflow

```
Root (meals/, bread/, docs/) 
    ↓ [npm run sync]
.dev/src/content/docs/
    ↓ [astro build]
dist/ (deployed site)
```

## Rule

**ALWAYS edit files in the ROOT directories** (`/meals/`, `/bread/`, `/docs/`)  
**NEVER edit files in `.dev/src/content/docs/`** - they will be overwritten

## Build Commands

```bash
cd .dev
npm run sync      # Copies root content to .dev/src/content/docs/
npm run build     # Builds the site
npm run dev       # Sync + build + dev server
```

## Exceptions

These `.dev/` files are SAFE to edit (not synced):
- `.dev/src/components/` - React/Astro components
- `.dev/src/pages/` - Custom pages (like meals/readme.astro)
- `.dev/src/styles/` - CSS files
- `.dev/public/` - Static assets (images, robots.txt, llms.txt generator)
- `.dev/astro.config.mjs` - Site configuration
- `.dev/scripts/` - Build scripts (except sync-content.js logic)
- `.dev/package.json` - Dependencies and scripts
