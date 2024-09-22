#!/bin/bash

# Check if README.md contains "## RFDs"
if grep -q '## RFDs' README.md; then
  # Extract everything before the "Requests for Discussion" section
  head -n $(grep -n '## RFDs' README.md | cut -d: -f1) README.md > temp_README.md
else
  # Copy the full README.md if no Requests for Discussion section exists
  cat README.md > temp_README.md
  echo "## RFDs" >> temp_README.md
fi

# Generate the table header
echo "| RFD | State | Updated | Labels |" >> temp_README.md
echo "|:----|:------|:--------|:-------|" >> temp_README.md

# Initialize an array to store the ordered table rows
rows=()

# Loop through files matching the NNNN.md pattern
for file in [0-9][0-9][0-9][0-9].md; do
  # Extract the RFD number from the filename
  rfd_number=$((10#$(basename "$file" .md)))

  # Extract the state from the front matter
  state=$(grep '^state:' "$file" | cut -d ' ' -f2-)

  # Extract the title from the first heading of the file
  title=$(grep -m 1 '^#' "$file" | sed 's/# RFD [0-9]\{1,4\} *//')

  # Get the last updated timestamp of the file and transform it to the YYYY-MM-DD, HH:MM format
  updated=$(git log -1 --format="%cI" -- "$file" | sed -E 's/T([0-9]{2}:[0-9]{2}):[0-9]{2}.*/, \1/')

  # Extract the labels from the front matter
  labels=$(grep '^labels:' "$file" | sed -E 's/labels: *//; s/ *, */, /g; s/([^, ]+)/`\1`/g')

  # Add the row to the table
  rows+=("| [RFD $rfd_number $title]($file) | $state | $updated | $labels |")
done

# Sort the rows array by the Updated column in descending order (newest first)
sorted_rows=$(printf "%s\n" "${rows[@]}" | sort -t '|' -k 4,4r)

# Add the sorted rows to the table
printf "%s\n" "$sorted_rows" >> temp_README.md

# Replace the original README.md with the updated one
mv temp_README.md README.md
