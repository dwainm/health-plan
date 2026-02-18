#!/bin/bash
#
# Build PDF cookbook from markdown files
# Generates family-health-plan.pdf
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
OUTPUT_PDF="$PROJECT_DIR/family-health-plan.pdf"

echo "Building Health Plan PDF..."
echo "Project directory: $PROJECT_DIR"
echo "Output: $OUTPUT_PDF"

# Check for required tools
if ! command -v pandoc &> /dev/null; then
    echo "Error: pandoc is required but not installed."
    echo "Install with: brew install pandoc"
    exit 1
fi

# Check for LaTeX (needed for PDF generation)
if ! command -v xelatex &> /dev/null; then
    echo "Warning: xelatex not found. Trying basic latex..."
    if ! command -v pdflatex &> /dev/null; then
        echo "Error: LaTeX is required for PDF generation."
        echo "Install with: brew install --cask mactex"
        echo "Or use the alternative markdown-to-pdf approach below."
        exit 1
    fi
fi

# Create temporary directory for build
BUILD_DIR=$(mktemp -d)
trap "rm -rf $BUILD_DIR" EXIT

# Create a combined markdown file in order
echo "Combining markdown files..."

# Start with title page
cat > "$BUILD_DIR/combined.md" << 'EOF'
---
title: "Family Health Plan"
subtitle: "A Simple Cookbook for Our Family of Six"
author: ""
date: ""
geometry: margin=1in
fontsize: 11pt
mainfont: "Helvetica"
sansfont: "Helvetica"
monofont: "Courier"
papersize: a4
linestretch: 1.4
header-includes:
  - \\usepackage{booktabs}
  - \\usepackage{longtable}
  - \\usepackage{enumitem}
  - \\setlist{nosep}
  - \\renewcommand\\familydefault{\\sfdefault}
---

\\thispagestyle{empty}

\\begin{center}
\\vspace*{3cm}

{\\Huge\\bfseries Family Health Plan}\\par
\\vspace{1cm}
{\\Large A Simple Cookbook for Our Family of Six}\\par
\\vspace{2cm}

{\\large \"Do everything as unto Him. This world will pass.\"}\\par
\\vspace{3cm}

{\\normalsize 
Simple, sustainable, faithful.\\par
Plant-based by default.\\par
Whole grains always.\\par
Resistance training.\\par
Grace over perfection.\\par
}

\\vfill

{\\small \\today}

\\end{center}

\\newpage

\\tableofcontents

\\newpage

EOF

# Function to add a file with proper section header
add_file() {
    local file="$1"
    local section_title="$2"
    
    if [ -f "$file" ]; then
        echo "" >> "$BUILD_DIR/combined.md"
        echo "# $section_title" >> "$BUILD_DIR/combined.md"
        echo "" >> "$BUILD_DIR/combined.md"
        # Remove the first h1 from the file (we just added it)
        tail -n +2 "$file" >> "$BUILD_DIR/combined.md"
        echo "" >> "$BUILD_DIR/combined.md"
        echo "\\newpage" >> "$BUILD_DIR/combined.md"
    fi
}

# Add files in order
add_file "$PROJECT_DIR/docs/principles.md" "Our Principles"
add_file "$PROJECT_DIR/meals/README.md" "The 30 Meals"
add_file "$PROJECT_DIR/meals/guest/README.md" "The 10 Guest Meals"
add_file "$PROJECT_DIR/bread/README.md" "Bread & Baking"
add_file "$PROJECT_DIR/bread/sourdough-bread.md" "Whole Grain Sourdough"
add_file "$PROJECT_DIR/bread/baguettes.md" "Whole Grain Baguettes"

# Add any recipe files
if [ -d "$PROJECT_DIR/recipes" ]; then
    for file in "$PROJECT_DIR"/recipes/*.md; do
        if [ -f "$file" ]; then
            filename=$(basename "$file" .md)
            # Convert filename to title (replace hyphens with spaces, capitalize)
            title=$(echo "$filename" | sed 's/-/ /g' | sed 's/\b\w/\u&/g')
            add_file "$file" "$title"
        fi
    done
fi

# Generate PDF
echo "Generating PDF with pandoc..."

pandoc "$BUILD_DIR/combined.md" \
    --output "$OUTPUT_PDF" \
    --pdf-engine=xelatex \
    --toc \
    --toc-depth=2 \
    --variable colorlinks=true \
    --variable linkcolor=teal \
    --variable urlcolor=teal \
    --variable toccolor=black \
    2>/dev/null || \
pandoc "$BUILD_DIR/combined.md" \
    --output "$OUTPUT_PDF" \
    --pdf-engine=pdflatex \
    --toc \
    --toc-depth=2 \
    2>/dev/null || {
        echo "PDF generation with LaTeX failed. Trying alternative method..."
        
        # Alternative: Use wkhtmltopdf if available
        if command -v wkhtmltopdf &> /dev/null; then
            echo "Using wkhtmltopdf..."
            # First build HTML
            "$SCRIPT_DIR/build-site.sh"
            # Then convert to PDF
            wkhtmltopdf \
                --enable-local-file-access \
                --page-size A4 \
                --margin-top 15mm \
                --margin-bottom 15mm \
                --margin-left 15mm \
                --margin-right 15mm \
                --encoding utf-8 \
                --title "Family Health Plan" \
                "$PROJECT_DIR/_site/index.html" \
                "$OUTPUT_PDF"
        else
            echo "Error: Could not generate PDF."
            echo "Please install either:"
            echo "  - MacTeX: brew install --cask mactex"
            echo "  - Or wkhtmltopdf: brew install --cask wkhtmltopdf"
            exit 1
        fi
    }

echo ""
echo "PDF generated successfully!"
echo "Output: $OUTPUT_PDF"
echo ""
echo "To print:"
echo "  - Duplex (double-sided)"
echo "  - Bind or staple left side"
echo "  - Cover page optional"
