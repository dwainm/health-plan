#!/bin/bash
#
# Build PDF using WeasyPrint (simpler alternative to LaTeX)
# Generates health-plan.pdf from the website HTML
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
OUTPUT_PDF="$PROJECT_DIR/health-plan.pdf"

echo "Building Health Plan PDF (simple method)..."

# Check for weasyprint
if ! command -v weasyprint &> /dev/null; then
    echo "Error: weasyprint not found."
    echo "Install with: pip install weasyprint"
    exit 1
fi

# First build the site
"$SCRIPT_DIR/build-site.sh"

# Create a combined HTML file for PDF
echo "Creating combined HTML..."

COMBINED_HTML="$PROJECT_DIR/_site/combined-for-pdf.html"

cat > "$COMBINED_HTML" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Health Plan</title>
    <style>
        @page {
            size: A4;
            margin: 2cm;
            @bottom-center {
                content: counter(page);
                font-size: 10pt;
            }
        }
        
        body {
            font-family: Georgia, "Times New Roman", serif;
            font-size: 11pt;
            line-height: 1.6;
            color: #333;
        }
        
        h1 {
            font-size: 24pt;
            color: #2c5530;
            border-bottom: 2px solid #8fbc8f;
            padding-bottom: 0.3cm;
            margin-top: 1cm;
            page-break-before: always;
        }
        
        h1:first-of-type {
            page-break-before: avoid;
        }
        
        h2 {
            font-size: 16pt;
            color: #2c5530;
            margin-top: 0.8cm;
        }
        
        h3 {
            font-size: 13pt;
            color: #5a7d5a;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 0.5cm 0;
            font-size: 10pt;
        }
        
        th, td {
            border: 1px solid #ddd;
            padding: 0.3cm;
            text-align: left;
        }
        
        th {
            background: #f0f0f0;
        }
        
        code {
            font-family: "Courier New", monospace;
            background: #f5f5f5;
            padding: 0.1cm 0.2cm;
            font-size: 9pt;
        }
        
        blockquote {
            border-left: 3px solid #8fbc8f;
            margin: 0.5cm 0;
            padding: 0.3cm 0.5cm;
            background: #f9f9f9;
            font-style: italic;
        }
        
        ul, ol {
            padding-left: 1cm;
        }
        
        li {
            margin: 0.2cm 0;
        }
        
        .cover {
            text-align: center;
            padding-top: 6cm;
        }
        
        .cover h1 {
            font-size: 36pt;
            border: none;
            page-break-before: avoid;
        }
        
        .cover p {
            font-size: 14pt;
            color: #666;
        }
        
        nav, footer {
            display: none;
        }
        
        a {
            color: #333;
            text-decoration: none;
        }
    </style>
</head>
<body>

<div class="cover">
    <h1>Health Plan</h1>
    <p style="margin-top: 2cm; font-style: italic;">"Do everything as unto Him. This world will pass."</p>
</div>

<h2>Principles</h2>

<ol>
<li><strong>First things first.</strong> This world will pass. Do everything as unto Him.</li>
<li><strong>Calorie density.</strong> Eat foods that fill you up with fewer calories. Starches, vegetables, legumes. Not oil, meat, processed food.</li>
<li><strong>Plant-based by default.</strong> Daily meals center on whole grains, beans, vegetables. Meat is a condiment, not the center.</li>
<li><strong>The 30 + 10.</strong> Thirty meals for daily life. Ten for guests. No more. No novelty hunting.</li>
<li><strong>Resistance first.</strong> Build muscle, raise BMR. Cardio for heart and enjoyment, not weight loss.</li>
<li><strong>Whole grains always.</strong> Brown rice, whole wheat, oats. More filling, same calories.</li>
<li><strong>Simplicity in shopping.</strong> Eighty percent the same every week. No exotic ingredients.</li>
<li><strong>Hospitality without compromise.</strong> Serve guests well. Keep your defaults as the base.</li>
<li><strong>The long game.</strong> Build a food culture, not a diet. Consistency beats intensity.</li>
<li><strong>Grace over perfection.</strong> Miss a day? Start again at the next meal.</li>
</ol>

EOF

# Function to extract body content from HTML and make IDs unique
extract_and_process() {
    local file="$1"
    local prefix="$2"
    
    # Extract content between <main> and </main>
    # Then replace heading IDs with unique prefixed versions
    sed -n '/<main>/,/<\/main>/p' "$file" | \
        sed 's/<main>//' | \
        sed 's/<\/main>//' | \
        sed 's/<nav>.*<\/nav>//g' | \
        sed 's/<footer>.*<\/footer>//g' | \
        sed -E "s/(<h[123][^>]*)id=\"([^\"]*)\"([^>]*)>/\1id=\"$prefix-\2\"\3>/g"
}

# Add each page with unique prefixes (principles already on page 1)
echo "Processing meals..."
extract_and_process "$PROJECT_DIR/_site/meals.html" "meals" >> "$COMBINED_HTML"

echo "Processing guest meals..."
extract_and_process "$PROJECT_DIR/_site/guest.html" "guest" >> "$COMBINED_HTML"

echo "Processing bread..."
extract_and_process "$PROJECT_DIR/_site/bread.html" "bread" >> "$COMBINED_HTML"

echo "Processing sourdough..."
extract_and_process "$PROJECT_DIR/_site/sourdough-bread.html" "sourdough" >> "$COMBINED_HTML"

echo "Processing baguettes..."
extract_and_process "$PROJECT_DIR/_site/baguettes.html" "baguettes" >> "$COMBINED_HTML"

# Add specialty meals with unique prefixes
echo "Processing specialty meals..."
for file in "$PROJECT_DIR/_site/meals/"*.html; do
    if [ -f "$file" ]; then
        filename=$(basename "$file" .html)
        prefix=$(echo "$filename" | sed 's/[^a-zA-Z0-9]/-/g' | tr '[:upper:]' '[:lower:]')
        extract_and_process "$file" "$prefix" >> "$COMBINED_HTML"
    fi
done

echo "</body></html>" >> "$COMBINED_HTML"

# Generate PDF
echo "Generating PDF with WeasyPrint..."
weasyprint "$COMBINED_HTML" "$OUTPUT_PDF" 2>&1 | grep -v "WARNING: Anchor defined twice" || true

# Clean up
rm "$COMBINED_HTML"

echo ""
echo "PDF generated successfully!"
echo "Output: $OUTPUT_PDF"
echo ""
ls -lh "$OUTPUT_PDF"
