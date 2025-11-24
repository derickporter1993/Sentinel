#!/bin/bash

# Script to close all open pull requests
# Requires GitHub CLI (gh) to be installed and authenticated

REPO="derickporter1993/Ops-Gurdian"

echo "Fetching all open pull requests for $REPO..."
echo ""

# Get list of open PRs
open_prs=$(gh pr list --repo "$REPO" --state open --json number,title,headRefName --jq '.[] | "\(.number)\t\(.title)\t\(.headRefName)"')

if [ -z "$open_prs" ]; then
    echo "No open pull requests found."
    exit 0
fi

echo "Open Pull Requests:"
echo "$open_prs"
echo ""
echo "---"
echo ""

# Count PRs
pr_count=$(echo "$open_prs" | wc -l)
echo "Found $pr_count open pull request(s)"
echo ""

# Ask for confirmation
read -p "Do you want to close all these PRs? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Aborted. No pull requests were closed."
    exit 0
fi

echo ""
echo "Closing pull requests..."
echo ""

# Close each PR
echo "$open_prs" | while IFS=$'\t' read -r number title branch; do
    echo "Closing PR #$number: $title"
    gh pr close "$number" --repo "$REPO" --comment "Closing as part of repository cleanup and consolidation."

    if [ $? -eq 0 ]; then
        echo "✓ Successfully closed PR #$number"
    else
        echo "✗ Failed to close PR #$number"
    fi
    echo ""
done

echo "Done!"
