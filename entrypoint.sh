#!/bin/sh -l

#
# Input verification
#
TOKEN=${INPUT_TOKEN}

if [ -z "${TOKEN}" ]; then
  >&2 printf "\nERR: Invalid input: 'token' is required, and must be specified.\n"
  >&2 printf "\tNote: It's necessary to interact with Github's API.\n\n"
  >&2 printf "Try:\n"
  >&2 printf "\tuses: repoloc/test.reponame/github-release@TAG\n"
  >&2 printf "\twith:\n"
  >&2 printf "\t  token: \${{ secrets.GITHUB_TOKEN }}\n"
  >&2 printf "\t  ...\n"
  exit 1
fi

# Try getting $TAG from action input
TAG=${INPUT_NEW_VERSION_TAG}

# If all ways of getting the TAG failed, exit with an error
if [ -z "${TAG}" ]; then
  >&2 printf "\nERR: Invalid input: 'tag' is required, and must be specified.\n"
  >&2 printf "Try:\n"
  >&2 printf "\tuses: repoloc/test.reponame/github-release@TAG\n"
  >&2 printf "\twith:\n"
  >&2 printf "\t  tag: v0.0.1\n"
  >&2 printf "\t  ...\n\n"
  >&2 printf "Note: To use dynamic TAG, set RELEASE_TAG env var in a prior step, ex:\n"
  >&2 printf '\techo ::set-env name=RELEASE_TAG::"v1.0.0"\n\n'
  exit 1
fi

BASE_URL="https://api.github.com/repos/${GITHUB_REPOSITORY}/releases"
echo "BASE_URL: ${BASE_URL}"
RELEASE_NAME="Release ${TAG}"

# JSON="{\"tag_name\": \"${TAG}\", \"name\": \"${RELEASE_NAME}\"}"

JSON=$(jq -n -r --arg tag_name "${TAG}" --arg name "${RELEASE_NAME}" '{tag_name: $tag_name, name: $name}')

CODE=$(curl -d "${JSON}" -X POST -H "Authorization: token ${TOKEN}" -H "Content-Type: application/json" "https://api.github.com/repos/${GITHUB_REPOSITORY}/releases")

echo ${CODE}
