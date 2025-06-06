#!/bin/bash

# Directory to search (default is current directory, change if needed)
SEARCH_DIR="${1:-.}"

# Check if pdftk is installed
if ! command -v pdftk >/dev/null 2>&1; then
    echo "Error: pdftk is not installed. Install it with 'sudo apt install pdftk' or equivalent."
    exit 1
fi

# Function to split a PDF
split_pdf() {
    local pdf_file="$1"
    local base_name=$(basename "$pdf_file" .pdf)
    local dir_name=$(dirname "$pdf_file")
    local output_prefix="${dir_name}/${base_name}_part"

    # Get the total number of pages
    total_pages=$(pdftk "$pdf_file" dump_data | grep "NumberOfPages" | awk '{print $2}')
    
    if [ -z "$total_pages" ]; then
        echo "Could not determine page count for $pdf_file. Skipping."
        return
    fi

    echo "Processing $pdf_file with $total_pages pages"

    # Skip if 100 pages or fewer
    if [ "$total_pages" -le 100 ]; then
        echo "$pdf_file has $total_pages pages (≤ 100), skipping."
        return
    fi

    # Calculate number of parts
    pages_per_part=100
    part=1
    start_page=1

    while [ "$start_page" -le "$total_pages" ]; do
        end_page=$((start_page + pages_per_part - 1))
        if [ "$end_page" -gt "$total_pages" ]; then
            end_page="$total_pages"
        fi

        output_file="${output_prefix}${part}.pdf"
        echo "Creating $output_file (pages $start_page to $end_page)"
        pdftk "$pdf_file" cat "$start_page-$end_page" output "$output_file"

        start_page=$((end_page + 1))
        part=$((part + 1))
    done

    echo "Finished splitting $pdf_file into $((part - 1)) parts."
}

# Export the function so it can be used by find
export -f split_pdf

# Find all PDFs recursively and process them
find "$SEARCH_DIR" -type f -iname "*.pdf" -exec bash -c 'split_pdf "$0"' {} \;

echo "All PDFs processed."