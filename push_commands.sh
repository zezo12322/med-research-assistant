#!/bin/bash

# Med Research Assistant - Push to GitHub Script
# Run these commands one by one after creating the GitHub repository

echo "=== Step 1: Set your GitHub username ==="
echo "Replace YOUR_USERNAME in the commands below with your actual GitHub username"
echo ""

echo "=== Step 2: Add GitHub remote ==="
echo "git remote add origin https://github.com/YOUR_USERNAME/med-research-assistant.git"
echo ""

echo "=== Step 3: Rename branch to main ==="
echo "git branch -M main"
echo ""

echo "=== Step 4: Push to GitHub ==="
echo "git push -u origin main"
echo ""

echo "=== All Done! ==="
echo "Your project will be live at: https://github.com/YOUR_USERNAME/med-research-assistant"
