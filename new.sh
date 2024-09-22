#!/bin/bash

# Fetch all remote branches following the pattern 'rfd/XXXX' and get the latest number
git fetch origin
latest_branch=$(git branch -r | grep -E 'origin/rfd/[0-9]{4}' | sed 's|origin/rfd/||' | sort -n | tail -1)

# Increment RFD number by one
if [ -z "$latest_branch" ]; then
    next_number=0001  # If no branch exists, start from 0001
else
    next_number=$(printf "%04d" $(( $(echo "$latest_branch" | sed 's/^0*//') + 1 )))
fi

# Prompt for the placeholder title of the RFD
echo "Enter the title for this RFD:"
read rfd_title

# Reserve the branch name for the new RFD
new_branch="rfd/$next_number"
git checkout -b "$new_branch"

# Generate a new RFD file from the template
new_file="${next_number}.md"
cp XXXX.md "$new_file"

# Update the new file by replacing <number> and <title> placeholders
sed -i "" "s/<number>/$((10#$next_number))/g" "$new_file"
sed -i "" "s/<title>/${rfd_title}/g" "$new_file"

# Get the current git user's name and email
author_name=$(git config user.name)
author_email=$(git config user.email)
author="${author_name} <${author_email}>"

# Append the author information to the existing 'authors' field in the front matter
sed -i "" "/^authors:/ s/$/ $author/" "$new_file"

# Git add the new file
git add "$new_file"

# Commit following the convention: 0000: Add placeholder for RFD <Title>
commit_message="$next_number: Adding placeholder for RFD $rfd_title"
git commit -m "$commit_message"

# Push the new branch to remote
git push origin "$new_branch"

echo "Branch $new_branch created and pushed with file $new_file."
