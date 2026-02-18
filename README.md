# Health Plan

A simple, sustainable approach to nutrition and health.

## Philosophy

> "Do everything as unto Him. This world will pass."

This cookbook is built on a few core principles that make healthy eating automatic—not a constant decision.

## Quick Start

- [Our Principles](docs/principles.md) — The foundation
- [The 30 Meals](meals/README.md) — Daily meals
- [The 10 Guest Meals](meals/guest/README.md) — For hosting
- [Specialty Meals](meals/specialty/README.md) — Trusted favorites
- [Techniques](docs/techniques/README.md) — Building blocks
- [Bread & Baking](bread/README.md) — Sourdough whole grain

## Project Structure

```
.
├── docs/
│   └── principles.md          # Core philosophy and guidelines
├── meals/
│   ├── breakfasts/            # 4 core breakfast patterns
│   ├── lunches/               # 4 core lunch patterns
│   ├── dinners/               # 22 dinner slots (6-8 cores + variations)
│   └── guest/                 # 10 meals for entertaining
├── bread/
│   ├── README.md              # Bread philosophy and basics
│   ├── sourdough-bread.md     # Whole grain sourdough loaf
│   └── baguettes.md           # Whole grain baguettes
├── recipes/                   # Detailed recipes (linked from meals)
└── scripts/
    ├── build-site.sh          # Generate static website
    └── build-pdf.sh           # Generate PDF cookbook
```

## Building

```bash
# Generate website
./scripts/build-site.sh

# Generate PDF
./scripts/build-pdf.sh
```

## Status

This is a living document. We add recipes slowly and only keep what works.

---

*Simple, sustainable, faithful.*
