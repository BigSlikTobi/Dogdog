#!/bin/bash

# Script to generate 2x and 3x image variants for Flutter app
# Requires ImageMagick to be installed: brew install imagemagick

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🖼️  Generating image variants for DogDog Trivia Game${NC}"

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo -e "${RED}❌ ImageMagick is not installed. Please install it first:${NC}"
    echo -e "${YELLOW}   brew install imagemagick${NC}"
    exit 1
fi

# Base directory
BASE_DIR="assets/images"
IMAGES_2X_DIR="$BASE_DIR/2.0x"
IMAGES_3X_DIR="$BASE_DIR/3.0x"

# Create directories if they don't exist
mkdir -p "$IMAGES_2X_DIR"
mkdir -p "$IMAGES_3X_DIR"

# List of images to process
IMAGES=(
    "chihuahua.png"
    "cocker.png"
    "dogge.png"
    "fail.png"
    "logo.png"
    "mops.png"
    "schaeferhund.png"
    "success1.png"
    "success2.png"
)

echo -e "${YELLOW}📋 Processing ${#IMAGES[@]} images...${NC}"

# Process each image
for image in "${IMAGES[@]}"; do
    base_image="$BASE_DIR/$image"
    
    if [ ! -f "$base_image" ]; then
        echo -e "${RED}❌ Base image not found: $base_image${NC}"
        continue
    fi
    
    echo -e "${GREEN}🔄 Processing: $image${NC}"
    
    # Get original dimensions
    original_width=$(identify -format "%w" "$base_image")
    original_height=$(identify -format "%h" "$base_image")
    
    echo "   Original size: ${original_width}x${original_height}"
    
    # Generate 2x version
    target_2x="$IMAGES_2X_DIR/$image"
    width_2x=$((original_width * 2))
    height_2x=$((original_height * 2))
    
    convert "$base_image" -resize "${width_2x}x${height_2x}" -quality 90 "$target_2x"
    echo "   ✅ Created 2x: ${width_2x}x${height_2x} -> $target_2x"
    
    # Generate 3x version
    target_3x="$IMAGES_3X_DIR/$image"
    width_3x=$((original_width * 3))
    height_3x=$((original_height * 3))
    
    convert "$base_image" -resize "${width_3x}x${height_3x}" -quality 90 "$target_3x"
    echo "   ✅ Created 3x: ${width_3x}x${height_3x} -> $target_3x"
done

echo -e "${GREEN}🎉 Image variant generation complete!${NC}"
echo -e "${YELLOW}📊 Summary:${NC}"
echo "   - Base images: ${#IMAGES[@]}"
echo "   - 2x variants: $(ls -1 "$IMAGES_2X_DIR"/*.png 2>/dev/null | wc -l | tr -d ' ')"
echo "   - 3x variants: $(ls -1 "$IMAGES_3X_DIR"/*.png 2>/dev/null | wc -l | tr -d ' ')"

# Calculate total file sizes
base_size=$(du -sh "$BASE_DIR"/*.png 2>/dev/null | awk '{sum+=$1} END {print sum}' || echo "0")
total_size=$(du -sh "$BASE_DIR" 2>/dev/null | awk '{print $1}' || echo "0")

echo "   - Total asset size: $total_size"

echo -e "${GREEN}✨ Ready for Flutter! Run 'flutter clean && flutter pub get' to refresh assets.${NC}"