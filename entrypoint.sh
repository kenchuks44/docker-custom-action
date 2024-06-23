#!/bin/sh

# Get GitHub Token and Giphy API Key from GitHub Actions inputs
GH_TOKEN=$1
GIPHY_API_KEY=$2

# Get PR number from GitHub event payload
pull_request_number=$(jq --raw-output .pull_request.number "$GITHUB_EVENT_PATH")
echo "PR Number - $pull_request_number"

# Fetch a random GIF with Giphy API
giphy_response=$(curl -s "https://api.giphy.com/v1/gifs/random?api_key=$GIPHY_API_KEY&tag=&rating=g")
echo "Giphy Response - $giphy_response"

# Extract GIF URL from Giphy response
gif_url=$(echo "$giphy_response" | jq --raw-output .data.images.downsized.url)
echo "GIPHY_URL - $gif_url"

# Create a comment with the GIF on the PR
comment_response=$(curl -L -X POST -H "Authorization: bearer $GH_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  -d '{"body": \"### PR - #$pull_request_number. \n ### Thank you \n ![GIF]($gif_url)\"}' \
  "https://api.github.com/repos/kenchuks44/docker-custom-action/issues/$pull_request_number/comments")

# Extract the comment URL from the response
comment_url=$(echo "$comment_response" | jq --raw-output .html_url)
