#!/bin/bash
#
# Generate monthly meal plan with 2-week rotation
# Usage: ./generate-monthly-plan.sh
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors for output
GREEN='\033[0;32m'
NC='\033[0m'

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

# Day names array (0=Sun, 1=Mon, ..., 6=Sat)
DAY_NAMES=("Sun" "Mon" "Tue" "Wed" "Thu" "Fri" "Sat")

# Calculate day of week for first day of month using Zeller's congruence
# Returns 0=Saturday, 1=Sunday, ..., 6=Friday
get_day_of_week() {
    local d=$1
    local m=$2
    local y=$3
    
    # Zeller's congruence adjustment
    local zeller_m=$m
    local zeller_y=$y
    
    if [ "$m" -lt 3 ]; then
        zeller_m=$((m + 12))
        zeller_y=$((y - 1))
    fi
    
    local k=$((zeller_y % 100))
    local j=$((zeller_y / 100))
    
    # Zeller: h = (q + 13(m+1)/5 + K + K/4 + J/4 + 5J) mod 7
    local h=$(( (d + (13 * (zeller_m + 1) / 5) + k + (k / 4) + (j / 4) + (5 * j)) % 7 ))
    
    # Convert to 0=Sun, 1=Mon, ..., 6=Sat
    local dow=$(( (h + 6) % 7 ))
    echo "$dow"
}

# First day of month day of week
first_dow=$(get_day_of_week 1 "$MONTH_NUM" "$YEAR")

# Define 2-week rotation - organized by day of week (0=Sun to 6=Sat)
get_meal() {
    local dow=$1
    local week=$2
    
    if [ "$week" -eq 1 ]; then
        case $dow in
            0) echo "Moroccan Lamb" ;;
            1) echo "Lentil Soup" ;;
            2) echo "Stir-fry" ;;
            3) echo "Pasta e Fagioli" ;;
            4) echo "Burrito Bowls" ;;
            5) echo "Simple Dal" ;;
            6) echo "Butter Chicken Curry" ;;
        esac
    else
        case $dow in
            0) echo "Lamb & Beef Pot" ;;
            1) echo "Chana Masala" ;;
            2) echo "Vegetable Curry" ;;
            3) echo "Bean Chili" ;;
            4) echo "Mediterranean Plate" ;;
            5) echo "Fried Rice" ;;
            6) echo "Seafood Pot" ;;
        esac
    fi
}

# Calorie estimates
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

# Determine starting week based on which Saturday has occurred
saturdays_passed=0
for ((d=1; d<START_DAY; d++)); do
    dow=$(( (first_dow + d - 1) % 7 ))
    if [ "$dow" -eq 6 ]; then
        saturdays_passed=$((saturdays_passed + 1))
    fi
done

# If we've passed an odd number of Saturdays, start on week 2
if [ $((saturdays_passed % 2)) -eq 0 ]; then
    current_week=1
else
    current_week=2
fi

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
Rotation: 2-week cycle (Sat-Sun specialty, Mon-Fri core)

================================================================================

WEEK 1 (Sat-Fri): Butter Chicken → Moroccan Lamb → Lentil → Stir-fry → Pasta → Burrito → Simple Dal
WEEK 2 (Sat-Fri): Seafood Pot → Lamb & Beef → Chana Masala → Veg Curry → Bean Chili → Med Plate → Fried Rice

================================================================================

EOF

# Generate daily plan
for ((day=START_DAY; day<=LAST_DAY; day++)); do
    dow=$(( (first_dow + day - 1) % 7 ))
    day_name="${DAY_NAMES[$dow]}"
    
    # Get meal for this day
    meal=$(get_meal "$dow" "$current_week")
    
    # Get calories
    calories=$(get_calories "$meal")
    
    # Write to file
    printf "%s %02d: %-25s ~%d cal/serving\n" "$day_name" "$day" "$meal" "$calories" >> "$OUTPUT_FILE"
    
    # Add lunch note (except for first day)
    if [ "$day" -gt "$START_DAY" ]; then
        printf "         Lunch: Leftovers (~%s portions)\n" "$LUNCH_PORTIONS" >> "$OUTPUT_FILE"
    fi
    
    echo "" >> "$OUTPUT_FILE"
    
    # Toggle week after Saturday
    if [ "$dow" -eq 6 ]; then
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
echo "Preview (first 25 lines):"
head -30 "$OUTPUT_FILE"
