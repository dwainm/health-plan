import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.join(__dirname, '..', '..');
const docsDir = path.join(__dirname, '..', 'src', 'content', 'docs');

// Ensure docs directory exists
if (!fs.existsSync(docsDir)) {
  fs.mkdirSync(docsDir, { recursive: true });
}

// Extract title from markdown content
function extractTitle(content) {
  const match = content.match(/^# (.+)$/m);
  return match ? match[1] : 'Untitled';
}

// Add frontmatter to content if it doesn't have it
function addFrontmatter(content, filePath) {
  if (content.startsWith('---')) {
    return content; // Already has frontmatter
  }
  
  const title = extractTitle(content);
  const frontmatter = `---
title: ${title}
---

`;
  
  // Remove the H1 title from content since Starlight displays it from frontmatter
  const contentWithoutH1 = content.replace(/^# .+\n\n?/, '');
  
  return frontmatter + contentWithoutH1;
}

// Sync content from root to docs
function syncContent() {
  const sections = ['meals', 'bread', 'docs'];
  
  sections.forEach(section => {
    const sourceDir = path.join(rootDir, section);
    const targetDir = path.join(docsDir, section);
    
    if (fs.existsSync(sourceDir)) {
      // Create target directory
      if (!fs.existsSync(targetDir)) {
        fs.mkdirSync(targetDir, { recursive: true });
      }
      
      // Copy markdown files
      const copyFiles = (src, dest) => {
        const items = fs.readdirSync(src, { withFileTypes: true });
        
        items.forEach(item => {
          const srcPath = path.join(src, item.name);
          const destPath = path.join(dest, item.name);
          
          if (item.isDirectory()) {
            if (!fs.existsSync(destPath)) {
              fs.mkdirSync(destPath, { recursive: true });
            }
            copyFiles(srcPath, destPath);
          } else if (item.name.endsWith('.md')) {
            const content = fs.readFileSync(srcPath, 'utf-8');
            const contentWithFrontmatter = addFrontmatter(content, srcPath);
            fs.writeFileSync(destPath, contentWithFrontmatter);
          }
        });
      };
      
      copyFiles(sourceDir, targetDir);
    }
  });
  
  // Copy images from meals/images to public/images
  const sourceImagesDir = path.join(rootDir, 'meals', 'images');
  const targetImagesDir = path.join(__dirname, '..', 'public', 'images', 'recipes');
  
  if (fs.existsSync(sourceImagesDir)) {
    if (!fs.existsSync(targetImagesDir)) {
      fs.mkdirSync(targetImagesDir, { recursive: true });
    }
    
    const imageFiles = fs.readdirSync(sourceImagesDir);
    imageFiles.forEach(file => {
      if (file.match(/\.(jpg|jpeg|png|webp|gif|svg)$/i)) {
        const srcPath = path.join(sourceImagesDir, file);
        const destPath = path.join(targetImagesDir, file);
        fs.copyFileSync(srcPath, destPath);
      }
    });
    console.log(`Copied ${imageFiles.length} images to public/images/recipes/`);
  }
  
  // Copy README as index with frontmatter
  const readmePath = path.join(rootDir, 'README.md');
  const indexPath = path.join(docsDir, 'index.md');
  if (fs.existsSync(readmePath)) {
    const content = fs.readFileSync(readmePath, 'utf-8');
    const contentWithFrontmatter = addFrontmatter(content, readmePath);
    fs.writeFileSync(indexPath, contentWithFrontmatter);
  }
}

syncContent();
console.log('Content synced successfully!');