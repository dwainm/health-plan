#!/bin/bash
# Download recipe images from Forks Over Knives
# Each image is named after the meal it represents

set -e

IMAGES_DIR="$(cd "$(dirname "$0")/.." && pwd)/meals/images"
mkdir -p "$IMAGES_DIR"

download_image() {
  local name="$1"
  local url="$2"

  echo "Fetching: $name"

  # Get the page HTML and extract og:image URL
  local html
  html=$(curl -sL -A "Mozilla/5.0" "$url" 2>/dev/null) || { echo "  FAILED to fetch page: $name"; return 1; }

  # Extract og:image content
  local img_url
  img_url=$(echo "$html" | perl -ne 'print $1 if /property="og:image"\s+content="([^"]+)"/' 2>/dev/null)

  if [ -z "$img_url" ]; then
    img_url=$(echo "$html" | perl -ne 'print $1 if /content="([^"]+)"\s+property="og:image"/' 2>/dev/null)
  fi

  if [ -z "$img_url" ]; then
    echo "  No og:image found for: $name"
    return 1
  fi

  echo "  Image URL: $img_url"

  # Determine extension from URL
  local ext="jpg"
  case "$img_url" in
    *.png*) ext="png" ;;
    *.webp*) ext="webp" ;;
  esac

  # Download the image
  local output="$IMAGES_DIR/${name}.${ext}"
  curl -sL -A "Mozilla/5.0" -o "$output" "$img_url" 2>/dev/null

  if [ -f "$output" ] && [ -s "$output" ]; then
    local size
    size=$(wc -c < "$output" | tr -d ' ')
    echo "  Saved: ${name}.${ext} (${size} bytes)"
  else
    echo "  FAILED to download: $name"
    rm -f "$output"
    return 1
  fi
}

echo "Downloading recipe images from Forks Over Knives..."
echo "Target directory: $IMAGES_DIR"
echo ""

success=0
failed=0

download_one() {
  if download_image "$1" "$2"; then
    success=$((success + 1))
  else
    failed=$((failed + 1))
  fi
  echo ""
  sleep 1
}

download_one "lentil-soup" "https://www.forksoverknives.com/recipes/vegan-soups-stews/lentil-vegetable-soup/"
download_one "chana-masala" "https://www.forksoverknives.com/recipes/vegan-soups-stews/slow-cooker-chana-masala/"
download_one "stir-fry" "https://www.forksoverknives.com/recipes/amazing-grains/ginger-soy-veggie-stir-fry/"
download_one "pasta" "https://www.forksoverknives.com/recipes/vegan-soups-stews/vegan-pasta-fagioli/"
download_one "burrito-bowls" "https://www.forksoverknives.com/recipes/amazing-grains/burrito-bowl/"
download_one "simple-dal" "https://www.forksoverknives.com/recipes/vegan-soups-stews/red-lentil-dal-recipe/"
download_one "vegetable-curry" "https://www.forksoverknives.com/recipes/amazing-grains/carleigh-bodrug-any-vegetable-curry/"
download_one "bean-chili" "https://www.forksoverknives.com/recipes/vegan-soups-stews/three-bean-chili-for-a-crowd/"
download_one "mediterranean-plate" "https://www.forksoverknives.com/recipes/vegan-snacks-appetizers/raw-and-roasted-vegetable-platter-with-herbed-hummus/"
download_one "fried-rice" "https://www.forksoverknives.com/recipes/amazing-grains/oil-free-tofu-fried-rice/"
download_one "vegetable-tagine" "https://www.forksoverknives.com/recipes/moroccan-chickpea-potato-tagine/"
download_one "oats" "https://www.forksoverknives.com/recipes/vegan-breakfast/fruit-and-nut-healthy-oatmeal/"
download_one "pancakes" "https://www.forksoverknives.com/how-tos/fluffy-whole-wheat-pancakes-recipe-plus-variations/"
download_one "smoothie-bowl" "https://www.forksoverknives.com/recipes/vegan-breakfast/mango-smoothie-bowl/"
download_one "moroccan-tagine" "https://www.forksoverknives.com/recipes/vegan-soups-stews/vegan-kefta-tagine-with-moroccan-meatballs/"
download_one "tikka-masala" "https://www.forksoverknives.com/recipes/vegan-soups-stews/vegetable-tikka-masala-curry/"

echo "Done! Downloaded $success images ($failed failed)"
