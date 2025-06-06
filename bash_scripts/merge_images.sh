#!/bin/bash

# Check if folder argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <folder_path>"
    exit 1
fi

FOLDER="$1"
OUTPUT_PDF="output.pdf"

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "Error: ImageMagick is not installed. Please install it first."
    echo "On Ubuntu/Debian: sudo apt-get install imagemagick"
    echo "On Fedora: sudo dnf install imagemagick"
    echo "On macOS: brew install imagemagick"
    exit 1
fi

# Check if the folder exists
if [ ! -d "$FOLDER" ]; then
    echo "Error: Folder '$FOLDER' does not exist"
    exit 1
fi

# Check if there are any JPG files in the folder
shopt -s nullglob
jpg_files=("$FOLDER"/*.jpg "$FOLDER"/*.JPG "$FOLDER"/*.jpeg "$FOLDER"/*.JPEG)
if [ ${#jpg_files[@]} -eq 0 ]; then
    echo "Error: No JPG files found in $FOLDER"
    exit 1
fi

# Combine all JPGs into a single PDF
convert "${jpg_files[@]}" "$OUTPUT_PDF"

# Check if the PDF was created successfully
if [ $? -eq 0 ]; then
    echo "PDF created successfully: $OUTPUT_PDF"
else
    echo "Error: Failed to create PDF"
    exit 1
fi