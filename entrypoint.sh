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

printf "The new TAG is: ${TAG}"

BASE_URL="https://api.github.com/repos/${GITHUB_REPOSITORY}/releases"

printf "The release repository URL is : ${BASE_URL}"

RELEASE_NAME="Release ${TAG}"

JSON=$(jq -n -r --arg tag_name "${TAG}" --arg name "${RELEASE_NAME}" '{tag_name: $tag_name, name: $name}')

if jq -e . >/dev/null 2>&1 <<<"$JSON"; then
    printf "Parsed JSON successfully and its value is : ${JSON}"
else
    printf "Failed to parse JSON: ${JSON}\n"
fi

STATUS=$(curl -d "${JSON}" -X POST -H "Authorization: token ${TOKEN}" -H "Content-Type: application/json" -o /dev/null -s -w "%{http_code}\n" "${BASE_URL}")

case "$STATUS" in
        200) printf "Received: HTTP $STATUS. The request has succeeded at $BASE_URL\n";;
        201) printf "Received: HTTP $STATUS, The $RELEASE_NAME created successfully at $BASE_URL\n";;
        422) printf "Received: HTTP $STATUS, The $RELEASE_NAME already exists at $BASE_URL\n";;
        404) printf "Received: HTTP $STATUS The URL $BASE_URL not found \n" ;;
          *) printf "Received: HTTP $STATUS at $BASE_URL\n" ;;
esac
