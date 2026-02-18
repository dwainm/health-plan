#!/bin/bash
#
# Generate a formatted text file for Apple Notes
# Copy the output and paste into a new note
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
OUTPUT_FILE="$PROJECT_DIR/health-plan-apple-notes.txt"

echo "Building Apple Notes version..."

# Build the site first to ensure we have latest HTML
"$SCRIPT_DIR/build-site.sh" > /dev/null 2>&1

# Create the formatted text file
cat > "$OUTPUT_FILE" << 'EOF'
HEALTH PLAN

"Do everything as unto Him. This world will pass."

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PRINCIPLES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. FIRST THINGS FIRST
   This world will pass. Do everything as unto Him.

2. CALORIE DENSITY
   Eat foods that fill you up with fewer calories.
   Starches, vegetables, legumes. Not oil, meat, processed food.

3. PLANT-BASED BY DEFAULT
   Daily meals center on whole grains, beans, vegetables.
   Meat is a condiment, not the center.

4. THE 30 + 10
   Thirty meals for daily life. Ten for guests.
   No more. No novelty hunting.

5. RESISTANCE FIRST
   Build muscle, raise BMR.
   Cardio for heart and enjoyment, not weight loss.

6. WHOLE GRAINS ALWAYS
   Brown rice, whole wheat, oats.
   More filling, same calories.

7. SIMPLICITY IN SHOPPING
   Eighty percent the same every week.
   No exotic ingredients.

8. HOSPITALITY WITHOUT COMPROMISE
   Serve guests well. Keep your defaults as the base.

9. THE LONG GAME
   Build a food culture, not a diet.
   Consistency beats intensity.

10. GRACE OVER PERFECTION
    Miss a day? Start again at the next meal.

EOF

# Function to add section header
add_section() {
    local title="$1"
    echo "" >> "$OUTPUT_FILE"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >> "$OUTPUT_FILE"
    echo "$title" >> "$OUTPUT_FILE"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
}

# Function to clean markdown and add to file
clean_md() {
    sed 's/^# //g' | \
    sed 's/^## //g' | \
    sed 's/^### //g' | \
    sed 's/^#### //g' | \
    sed 's/^- //g' | \
    sed 's/^  - //g' | \
    sed 's/^    - //g' | \
    sed 's/`//g' | \
    sed 's/\*\*//g' | \
    sed 's/\*//g' | \
    sed 's/\[//g' | \
    sed 's/\]([^)]*)//g' | \
    sed 's/| /  /g' | \
    sed 's/ |/  /g' | \
    sed 's/|//g' | \
    sed '/^---$/d' | \
    sed '/^→ /d' | \
    grep -v '^\s*[-=]\{3,\}\s*$' | \
    cat -s
}

# Add THE 30 MEALS
add_section "THE 30 MEALS"

cat >> "$OUTPUT_FILE" << 'EOF'
BREAKFASTS (4)
• Oats — steel-cut, rolled, or overnight
• Whole grain toast — peanut butter, avocado, eggs
• Pancakes — whole wheat, oat, or buckwheat  
• Smoothie bowl — fruit + oats + nut butter

LUNCHES (4)
• Leftovers — dinner becomes lunch
• Soup + bread — bean, lentil, vegetable
• Grain bowl — rice, quinoa, or farro base
• Simple sandwich — whole grain, hummus, vegetables

DINNERS — Core 8
• Lentil/Bean Soup — with variations
• Curry — dal, chickpea, or vegetable
• Chili — with cornbread or baked potato
• Pasta — whole wheat, marinara or aglio e olio
• Stir-fry — tofu/vegetables with rice
• Burrito Bowls — beans, rice, salsa, guac
• Mediterranean Plate — hummus, falafel, salads
• Simple Dal + Rice — emergency 30-min meal

EOF

# Add GUEST MEALS
add_section "GUEST MEALS (10)"

cat >> "$OUTPUT_FILE" << 'EOF'
• Lentil Moussaka
• Vegetable Lasagna
• Tagine (vegetable/chickpea)
• Taco Bar
• Mezze Spread
• Curry Feast
• Minestrone + Bread
• Butternut Soup + Salad
• Braai Sides Feast
• Grain Bowl Bar

EOF

# Add SPECIALTY MEALS
add_section "SPECIALTY MEALS"

cat >> "$OUTPUT_FILE" << 'EOF'
BUTTER CHICKEN CURRY
• Onions, garlic, ginger, butter
• Tomato paste, whole tomatoes
• Butter chicken spice, bay leaves
• Chicken thighs, dates, peppers
• Cashews, coriander
• Serve with jasmine rice

MOROCCAN LAMB
• Lamb or sheep, onions, garlic, ginger
• Spice blend: paprika, cumin, cinnamon, ginger, dates
• Carrots, sweet potato, baby potatoes, peppers
• Red wine, chakalaka soup
• Serve with couscous or rice

LAMB & BEEF POT
• Mixed stewing meats
• Onions, garlic, ginger
• Sweet potato, carrots, baby potatoes
• Red wine, chakalaka soup
• Pressure cooker 35 min

SEAFOOD POT
• Bacon, onions, peppers, mushrooms
• White wine, tomatoes, cream
• Mussels, prawns, calamari, white fish
• Lemon, garlic, seafood spices
• Serve with crusty bread

EOF

# Add BREAD
add_section "BREAD"

cat >> "$OUTPUT_FILE" << 'EOF'
SOURDOUGH BREAD
• 800g whole wheat flour
• 200g bread flour
• 750g water
• 20g salt
• 200g active starter

Method: Mix, fold 4x over 3hrs, shape, cold proof overnight, bake 250°C covered 20min + 230°C uncovered 25-30min.

BAGUETTES
Same dough. Shape into logs. Proof 1-2hrs. Bake with steam.

EOF

# Add TECHNIQUES
add_section "TECHNIQUES"

cat >> "$OUTPUT_FILE" << 'EOF'
PRESSURE COOKER RICE
• 2 cups rice + 2 cups water + 1.5 tsp salt
• Rinse until clear
• Low pressure 3 min, keep warm 10 min
• Release steam, fluff

Variations:
• Coconut rice — replace ½ cup water with coconut milk
• Herb rice — add bay leaf, thyme, cardamom
• Turmeric rice — add ½ tsp turmeric

EOF

echo "" >> "$OUTPUT_FILE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >> "$OUTPUT_FILE"
echo "github.com/dwainm/health-plan" >> "$OUTPUT_FILE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >> "$OUTPUT_FILE"

echo ""
echo "Apple Notes version created!"
echo "Output: $OUTPUT_FILE"
echo ""
echo "To use:"
echo "  1. Open the file: cat $OUTPUT_FILE | pbcopy"
echo "  2. Or: open $OUTPUT_FILE"
echo "  3. Copy all content"
echo "  4. Open Apple Notes"
echo "  5. Create new note, paste"
echo ""
ls -lh "$OUTPUT_FILE"
