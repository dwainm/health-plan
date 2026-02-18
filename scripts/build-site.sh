#!/bin/bash
#
# Build static website from markdown files
# Generates HTML site in _site/ directory
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/_site"

echo "Building Health Plan website..."
echo "Project directory: $PROJECT_DIR"
echo "Build directory: $BUILD_DIR"

# Clean and create build directory
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Check for required tools
if ! command -v pandoc &> /dev/null; then
    echo "Error: pandoc is required but not installed."
    echo "Install with: brew install pandoc"
    exit 1
fi

# Create HTML template
cat > "$BUILD_DIR/template.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$title$ - Health Plan</title>
    <style>
        :root {
            --color-primary: #2c5530;
            --color-secondary: #5a7d5a;
            --color-accent: #8fbc8f;
            --color-bg: #fafafa;
            --color-text: #333;
            --color-light: #f0f0f0;
            --max-width: 800px;
        }
        
        * {
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            line-height: 1.7;
            color: var(--color-text);
            background: var(--color-bg);
            margin: 0;
            padding: 0;
        }
        
        header {
            background: var(--color-primary);
            color: white;
            padding: 2rem 1rem;
            text-align: center;
        }
        
        header h1 {
            margin: 0;
            font-size: 1.8rem;
            font-weight: 300;
        }
        
        header p {
            margin: 0.5rem 0 0;
            opacity: 0.9;
        }
        
        nav {
            background: var(--color-light);
            padding: 1rem;
            border-bottom: 1px solid #ddd;
        }
        
        nav ul {
            list-style: none;
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            flex-wrap: wrap;
            gap: 1.5rem;
        }
        
        nav a {
            color: var(--color-primary);
            text-decoration: none;
            font-weight: 500;
        }
        
        nav a:hover {
            text-decoration: underline;
        }
        
        main {
            max-width: var(--max-width);
            margin: 0 auto;
            padding: 2rem 1.5rem;
            background: white;
            min-height: calc(100vh - 200px);
        }
        
        h1, h2, h3 {
            color: var(--color-primary);
            margin-top: 2rem;
            margin-bottom: 1rem;
        }
        
        h1 { font-size: 2rem; border-bottom: 2px solid var(--color-accent); padding-bottom: 0.5rem; }
        h2 { font-size: 1.5rem; }
        h3 { font-size: 1.2rem; }
        
        a {
            color: var(--color-secondary);
        }
        
        a:hover {
            color: var(--color-primary);
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 1.5rem 0;
        }
        
        th, td {
            padding: 0.75rem;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        
        th {
            background: var(--color-light);
            font-weight: 600;
        }
        
        tr:hover {
            background: #f9f9f9;
        }
        
        code {
            background: var(--color-light);
            padding: 0.2rem 0.4rem;
            border-radius: 3px;
            font-family: "SF Mono", Monaco, monospace;
            font-size: 0.9em;
        }
        
        pre {
            background: #2d2d2d;
            color: #f8f8f2;
            padding: 1rem;
            border-radius: 5px;
            overflow-x: auto;
        }
        
        pre code {
            background: none;
            padding: 0;
        }
        
        blockquote {
            border-left: 4px solid var(--color-accent);
            margin: 1.5rem 0;
            padding: 0.5rem 1rem;
            background: var(--color-light);
            font-style: italic;
        }
        
        ul, ol {
            padding-left: 1.5rem;
        }
        
        li {
            margin: 0.5rem 0;
        }
        
        footer {
            background: var(--color-light);
            text-align: center;
            padding: 2rem;
            color: #666;
            font-size: 0.9rem;
        }
        
        .checklist {
            list-style: none;
            padding-left: 0;
        }
        
        .checklist li::before {
            content: "☐ ";
            color: var(--color-secondary);
        }
        
        @media print {
            header, nav, footer {
                display: none;
            }
            main {
                max-width: none;
                padding: 0;
            }
        }
    </style>
</head>
<body>
    <header>
        <h1>Health Plan</h1>
        <p>Simple, sustainable, faithful</p>
    </header>
    
    <nav>
        <ul>
            <li><a href="index.html">Home</a></li>
            <li><a href="principles.html">Principles</a></li>
            <li><a href="meals.html">The 30 Meals</a></li>
            <li><a href="guest.html">Guest Meals</a></li>
            <li><a href="bread.html">Bread</a></li>
        </ul>
    </nav>
    
    <main>
        $body$
    </main>
    
    <footer>
        <p>Do everything as unto Him.</p>
    </footer>
</body>
</html>
EOF

# Function to convert markdown to HTML
convert_file() {
    local input="$1"
    local output="$2"
    local title="$3"
    
    pandoc "$input" \
        --template="$BUILD_DIR/template.html" \
        --variable title="$title" \
        --from markdown \
        --to html \
        --output "$output"
}

# Copy images if any
if [ -d "$PROJECT_DIR/images" ]; then
    cp -r "$PROJECT_DIR/images" "$BUILD_DIR/"
fi

# Convert main pages
echo "Converting main pages..."

convert_file "$PROJECT_DIR/README.md" "$BUILD_DIR/index.html" "Home"
convert_file "$PROJECT_DIR/docs/principles.md" "$BUILD_DIR/principles.html" "Principles"
convert_file "$PROJECT_DIR/meals/README.md" "$BUILD_DIR/meals.html" "The 30 Meals"
convert_file "$PROJECT_DIR/meals/guest/README.md" "$BUILD_DIR/guest.html" "Guest Meals"
convert_file "$PROJECT_DIR/bread/README.md" "$BUILD_DIR/bread.html" "Bread & Baking"

# Convert bread recipes
convert_file "$PROJECT_DIR/bread/sourdough-bread.md" "$BUILD_DIR/sourdough-bread.html" "Sourdough Bread"
convert_file "$PROJECT_DIR/bread/baguettes.md" "$BUILD_DIR/baguettes.html" "Baguettes"

# Create meals subdirectory
mkdir -p "$BUILD_DIR/meals"

# Convert meal files if they exist
for file in "$PROJECT_DIR"/meals/*/*.md; do
    if [ -f "$file" ]; then
        filename=$(basename "$file" .md)
        convert_file "$file" "$BUILD_DIR/meals/$filename.html" "$filename"
    fi
done

# Convert recipe files if they exist
if [ -d "$PROJECT_DIR/recipes" ]; then
    mkdir -p "$BUILD_DIR/recipes"
    for file in "$PROJECT_DIR"/recipes/*.md; do
        if [ -f "$file" ]; then
            filename=$(basename "$file" .md)
            convert_file "$file" "$BUILD_DIR/recipes/$filename.html" "$filename"
        fi
    done
fi

# Remove template file
rm "$BUILD_DIR/template.html"

# Create a simple index of all pages
cat > "$BUILD_DIR/sitemap.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sitemap - Health Plan</title>
    <style>
        body { font-family: system-ui, sans-serif; max-width: 800px; margin: 2rem auto; padding: 0 1rem; }
        h1 { color: #2c5530; }
        ul { line-height: 2; }
        a { color: #5a7d5a; }
    </style>
</head>
<body>
    <h1>All Pages</h1>
    <ul>
EOF

# Add links to sitemap
find "$BUILD_DIR" -name "*.html" -type f | sort | while read -r file; do
    rel_path="${file#$BUILD_DIR/}"
    name=$(basename "$rel_path" .html)
    echo "        <li><a href=\"$rel_path\">$name</a></li>" >> "$BUILD_DIR/sitemap.html"
done

cat >> "$BUILD_DIR/sitemap.html" << 'EOF'
    </ul>
</body>
</html>
EOF

echo ""
echo "Build complete!"
echo "Website generated in: $BUILD_DIR"
echo ""
echo "To view locally:"
echo "  cd $BUILD_DIR && python3 -m http.server 8000"
echo "  Then open http://localhost:8000"
echo ""
echo "To deploy:"
echo "  Upload contents of $BUILD_DIR to your web host"
