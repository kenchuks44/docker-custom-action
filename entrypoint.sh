#!/bin/sh

# Get GitHub Token and Tenor API Key from GitHub Actions inputs
GH_TOKEN=$1
GIPHY_API_KEY=$2

# Get PR number from GitHub event payload
pull_request_number=$(jq --raw-output .pull_request.number "$GITHUB_EVENT_PATH")
echo "PR Number - $pull_request_number"

# Fetch GIFs from Tenor API
tenor_response=$(curl -s "https://tenor.googleapis.com/v2/search?q=excited&key=$GIPHY_API_KEY&client_key=my_test_app&limit=8")
echo "Tenor Response - $tenor_response"

# Extract GIF URL from Tenor response
gif_url=$(echo "$tenor_response" | jq --raw-output .results[0].media_formats.gif.url)
echo "Tenor GIF URL - $gif_url"

# Verify required variables
echo "GitHub Token: $GH_TOKEN"
echo "Tenor API Key: $GIPHY_API_KEY"
echo "GitHub Repository: $GITHUB_REPOSITORY"

# Create JSON payload for GitHub comment
comment_data=$(jq -n \
  --arg body "### PR - #$pull_request_number \n ### Thank you for your contributions! \n ![GIF]($gif_url)" \
  '{body: $body}')
echo "Comment Data - $comment_data"

# Create a comment with the GIF on the PR
comment_response=$(curl -v -L -X POST -H "Authorization: bearer $GH_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  -H "Content-Type: application/json" \
  -d "$comment_data" \
  "https://api.github.com/repos/$GITHUB_REPOSITORY/issues/$pull_request_number/comments")

# Print the entire response for debugging
echo "Comment Response - $comment_response"

# Extract the comment URL from the response
comment_url=$(echo "$comment_response" | jq --raw-output .html_url)

# Check if the comment was successfully created
if [ "$comment_url" == "null" ]; then
  echo "Error creating comment on GitHub: $comment_response"
  exit 1
fi

echo "Comment successfully created: $comment_url"
