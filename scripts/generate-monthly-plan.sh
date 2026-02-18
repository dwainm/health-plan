#!/bin/bash
#
# Generate monthly meal plan with 2-week rotation
# Usage: ./generate-monthly-plan.sh
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================"
echo "    MONTHLY MEAL PLAN GENERATOR"
echo "========================================"
echo ""

# Get month and year
read -p "Enter month (e.g., March 2026): " MONTH_YEAR

# Parse month and year
MONTH=$(echo "$MONTH_YEAR" | awk '{print $1}')
YEAR=$(echo "$MONTH_YEAR" | awk '{print $2}')

if [ -z "$YEAR" ]; then
    YEAR=$(date +%Y)
fi

# Convert month name to number
case $(echo "$MONTH" | tr '[:upper:]' '[:lower:]') in
    january|jan) MONTH_NUM=01 ;;
    february|feb) MONTH_NUM=02 ;;
    march|mar) MONTH_NUM=03 ;;
    april|apr) MONTH_NUM=04 ;;
    may) MONTH_NUM=05 ;;
    june|jun) MONTH_NUM=06 ;;
    july|jul) MONTH_NUM=07 ;;
    august|aug) MONTH_NUM=08 ;;
    september|sep) MONTH_NUM=09 ;;
    october|oct) MONTH_NUM=10 ;;
    november|nov) MONTH_NUM=11 ;;
    december|dec) MONTH_NUM=12 ;;
    *) echo "Invalid month"; exit 1 ;;
esac

# Get number of people
read -p "How many people? " NUM_PEOPLE
if ! [[ "$NUM_PEOPLE" =~ ^[0-9]+$ ]]; then
    echo "Please enter a valid number"
    exit 1
fi

LUNCH_PORTIONS=$((NUM_PEOPLE / 2))
if [ $((NUM_PEOPLE % 2)) -ne 0 ]; then
    LUNCH_PORTIONS="$LUNCH_PORTIONS-=$((LUNCH_PORTIONS + 1))"
fi

echo ""
echo "Configuration:"
echo "  Month: $MONTH $YEAR"
echo "  People: $NUM_PEOPLE"
echo "  Lunch portions: ~$LUNCH_PORTIONS (leftovers)"
echo ""

# Calculate days in month
# Use a simple approach for cross-platform compatibility
get_days_in_month() {
    local year=$1
    local month=$2
    case $month in
        01|03|05|07|08|10|12) echo 31 ;;
        04|06|09|11) echo 30 ;;
        02) 
            if [ $((year % 4)) -eq 0 ] && [ $((year % 100)) -ne 0 ] || [ $((year % 400)) -eq 0 ]; then
                echo 29
            else
                echo 28
            fi
            ;;
        *) echo 30 ;;
    esac
}

LAST_DAY=$(get_days_in_month "$YEAR" "$MONTH_NUM")

# Get current day to calculate remaining days
TODAY=$(date +%d)
CURRENT_MONTH=$(date +%m)
CURRENT_YEAR=$(date +%Y)

# Determine start day
if [ "$MONTH_NUM" -eq "$CURRENT_MONTH" ] && [ "$YEAR" -eq "$CURRENT_YEAR" ]; then
    START_DAY=$TODAY
    echo "Generating plan from today (day $START_DAY) to end of month"
else
    START_DAY=1
    echo "Generating full month plan (days 1-$LAST_DAY)"
fi

# Define 2-week rotation using indexed arrays
WEEK1_SAT="Butter Chicken Curry"
WEEK1_SUN="Moroccan Lamb"
WEEK1_MON="Lentil Soup"
WEEK1_TUE="Stir-fry"
WEEK1_WED="Pasta e Fagioli"
WEEK1_THU="Burrito Bowls"
WEEK1_FRI="Simple Dal"

WEEK2_SAT="Seafood Pot"
WEEK2_SUN="Lamb & Beef Pot"
WEEK2_MON="Chana Masala"
WEEK2_TUE="Vegetable Curry"
WEEK2_WED="Bean Chili"
WEEK2_THU="Mediterranean Plate"
WEEK2_FRI="Fried Rice"

# Calorie estimates (placeholder - should be in recipe files)
get_calories() {
    case "$1" in
        "Butter Chicken Curry") echo 650 ;;
        "Moroccan Lamb") echo 720 ;;
        "Lentil Soup") echo 420 ;;
        "Stir-fry") echo 480 ;;
        "Pasta e Fagioli") echo 520 ;;
        "Burrito Bowls") echo 580 ;;
        "Simple Dal") echo 450 ;;
        "Seafood Pot") echo 680 ;;
        "Lamb & Beef Pot") echo 750 ;;
        "Chana Masala") echo 460 ;;
        "Vegetable Curry") echo 440 ;;
        "Bean Chili") echo 490 ;;
        "Mediterranean Plate") echo 510 ;;
        "Fried Rice") echo 520 ;;
        *) echo 500 ;;
    esac
}

# Generate output filename
MONTH_LOWER=$(echo "$MONTH" | tr '[:upper:]' '[:lower:]')
OUTPUT_FILE="$PROJECT_DIR/output/${MONTH_LOWER}-${YEAR}-meal-plan.txt"
mkdir -p "$PROJECT_DIR/output"

# Generate header
cat > "$OUTPUT_FILE" << EOF
$(echo "$MONTH $YEAR" | tr '[:lower:]' '[:upper:]') MEAL PLAN
================================================================================

People: $NUM_PEOPLE
Lunch portions: ~$LUNCH_PORTIONS (leftovers from previous dinner)

================================================================================

EOF

# Calculate starting day of week (1=Monday, 7=Sunday)
# Simple approximation: use day 1 of month to calculate
day_of_week=$(date -d "$YEAR-$MONTH_NUM-01" +%u 2>/dev/null || echo "1")

# Adjust for start day
offset=$((START_DAY - 1))
day_of_week=$(((day_of_week + offset - 1) % 7 + 1))

current_week=1

for ((day=START_DAY; day<=LAST_DAY; day++)); do
    # Determine day name
    day_name=$(date -d "$YEAR-$MONTH_NUM-$day" +%a 2>/dev/null || echo "Day")
    
    # Determine meal based on day of week
    if [ "$day_of_week" -eq 6 ]; then
        # Saturday
        if [ "$current_week" -eq 1 ]; then
            meal="$WEEK1_SAT"
        else
            meal="$WEEK2_SAT"
        fi
    elif [ "$day_of_week" -eq 7 ]; then
        # Sunday
        if [ "$current_week" -eq 1 ]; then
            meal="$WEEK1_SUN"
        else
            meal="$WEEK2_SUN"
        fi
    elif [ "$day_of_week" -eq 1 ]; then
        # Monday
        if [ "$current_week" -eq 1 ]; then
            meal="$WEEK1_MON"
        else
            meal="$WEEK2_MON"
        fi
    elif [ "$day_of_week" -eq 2 ]; then
        # Tuesday
        if [ "$current_week" -eq 1 ]; then
            meal="$WEEK1_TUE"
        else
            meal="$WEEK2_TUE"
        fi
    elif [ "$day_of_week" -eq 3 ]; then
        # Wednesday
        if [ "$current_week" -eq 1 ]; then
            meal="$WEEK1_WED"
        else
            meal="$WEEK2_WED"
        fi
    elif [ "$day_of_week" -eq 4 ]; then
        # Thursday
        if [ "$current_week" -eq 1 ]; then
            meal="$WEEK1_THU"
        else
            meal="$WEEK2_THU"
        fi
    else
        # Friday (5)
        if [ "$current_week" -eq 1 ]; then
            meal="$WEEK1_FRI"
        else
            meal="$WEEK2_FRI"
        fi
    fi
    
    # Get calories
    calories=$(get_calories "$meal")
    
    # Write to file
    printf "%s %02d: %-25s ~%d cal/serving\n" "$day_name" "$day" "$meal" "$calories" >> "$OUTPUT_FILE"
    
    # Add lunch note (except for first day)
    if [ "$day" -gt "$START_DAY" ]; then
        printf "         Lunch: Leftovers (~%s portions)\n" "$LUNCH_PORTIONS" >> "$OUTPUT_FILE"
    fi
    
    echo "" >> "$OUTPUT_FILE"
    
    # Increment day of week
    day_of_week=$((day_of_week + 1))
    if [ "$day_of_week" -gt 7 ]; then
        day_of_week=1
        # Toggle week
        if [ "$current_week" -eq 1 ]; then
            current_week=2
        else
            current_week=1
        fi
    fi
done

# Add shopping list section
cat >> "$OUTPUT_FILE" << EOF

================================================================================
SHOPPING LIST (ESTIMATED)
================================================================================

GRAINS:
  [ ] Rice: ___ kg
  [ ] Pasta: ___ kg
  [ ] Bread flour: ___ kg
  [ ] Whole wheat flour: ___ kg
  [ ] Oats: ___ kg

LEGUMES:
  [ ] Lentils (red/green): ___ kg
  [ ] Chickpeas: ___ kg
  [ ] Black beans: ___ kg
  [ ] Kidney beans: ___ kg

PROTEINS:
  [ ] Chicken: ___ kg
  [ ] Lamb/beef: ___ kg
  [ ] Fish/seafood: ___ kg
  [ ] Eggs: ___ dozen

VEGETABLES:
  [ ] Onions: ___ kg
  [ ] Garlic: ___ bulbs
  [ ] Ginger: ___ g
  [ ] Tomatoes: ___ kg
  [ ] Peppers: ___ kg
  [ ] Carrots: ___ kg
  [ ] Leafy greens: ___ bunches
  [ ] Potatoes: ___ kg

OTHER:
  [ ] Coconut milk: ___ cans
  [ ] Spices: check inventory
  [ ] Olive oil: check level
  [ ] Salt: check level

================================================================================

NOTES:
- Adjust quantities based on actual appetite
- Buy vegetables fresh weekly
- Check freezer before buying meat
- Lunch = leftovers from previous dinner

Generated: $(date)
EOF

echo ""
echo -e "${GREEN}Meal plan generated!${NC}"
echo "Output: $OUTPUT_FILE"
echo ""
ls -lh "$OUTPUT_FILE"
echo ""
echo "Preview:"
head -40 "$OUTPUT_FILE"
