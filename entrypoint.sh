#!/bin/sh -l

#
# Input verification
#
TOKEN=INPUT_TOKEN
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
TAG=INPUT_NEW_VERSION_TAG

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

JSON="{\"tag_name\": \"${TAG}\", \"name\": \"${RELEASE_NAME}\"}"

CODE=$(curl -d "${JSON}" -X POST -H "Authorization: token ${TOKEN}" -H "Content-Type: application/json" "https://api.github.com/repos/${GITHUB_REPOSITORY}/releases")

echo $CODE
#
# ## Handle, and prepare assets
# #
# # If no `files:` passed as input, but `RELEASE_FILES` env var is set, use it instead
# if [ -z "${INPUT_FILES}" ] && [ -n "${RELEASE_FILES}" ]; then
#   INPUT_FILES="${RELEASE_FILES}"
# fi

# if [ -z "${INPUT_FILES}" ]; then
#   >&2 echo "No assets to upload. All done."
#   exit 0
# fi

# ASSETS="${HOME}/assets"

# mkdir -p "${ASSETS}/"

# # this loop splits files by the space
# for entry in $(echo "${INPUT_FILES}" | tr ' ' '\n'); do
#   ASSET_NAME="${entry}"

#   # Well, that needs explaining…  If delimiter given in `-d` does not occur in string, `cut` always returns
#   #   the original string, no matter what the field `-f` specifies.
#   #
#   # I'm prepanding `:` to `${entry}` in `echo` to ensure match happens, because once it does, `-f` is respected,
#   #   and I can easily check fields, and that way:
#   #   * `-f 2` always contains the name of the asset
#   #   * `-f 3` is either the custom name of the asset,
#   #   * `-f 3` is empty, and needs to be set to `-f 2`
#   ASSET_NAME="$(echo ":${entry}" | cut -d: -f2)"
#   ASSET_PATH="$(echo ":${entry}" | cut -d: -f3)"

#   if [ -z "${ASSET_PATH}" ]; then
#     ASSET_NAME="$(basename "${entry}")"
#     ASSET_PATH="${entry}"
#   fi

#   # this loop, expands possible globs
#   for file in ${ASSET_PATH}; do
#     # Error out on the only illegal combination: compression disabled, and folder provided
#     if [ "${INPUT_GZIP}" = "false" ] && [ -d "${file}" ]; then
#         >&2 printf "\nERR: Invalid configuration: 'gzip' cannot be set to 'false' while there are 'folders/' provided.\n"
#         >&2 printf "\tNote: Either set 'gzip: folders', or remove directories from the 'files:' list.\n\n"
#         >&2 printf "Try:\n"
#         >&2 printf "\tuses: repoloc/test.reponame/github-release@TAG\n"
#         >&2 printf "\twith:\n"
#         >&2 printf "\t  ...\n"
#         >&2 printf "\t  gzip: folders\n"
#         >&2 printf "\t  files: >\n"
#         >&2 printf "\t    README.md\n"
#         >&2 printf "\t    my-artifacts/\n"
#         exit 1
#     fi

#     # Just copy files, if compression not enabled for all
#     if [ "${INPUT_GZIP}" != "true" ] && [ -f "${file}" ]; then
#       cp "${file}" "${ASSETS}/${ASSET_NAME}"
#       continue
#     fi

#     # In any other case compress
#     tar -cf "${ASSETS}/${ASSET_NAME}.tgz"  "${file}"
#   done
# done

# # At this point all assets to-be-uploaded (if any), are in `${ASSETS}/` folder
# echo "Files to be uploaded to Github:"
# ls "${ASSETS}/"

# UPLOAD_URL="$(echo "${BASE_URL}" | sed -e 's/api/uploads/')"

# for asset in "${ASSETS}"/*; do
#   FILE_NAME="$(basename "${asset}")"

#   CODE="$(curl -sS  -X POST \
#     --write-out "%{http_code}" -o "/tmp/${FILE_NAME}.json" \
#     -H "Authorization: token ${TOKEN}" \
#     -H "Content-Length: $(stat -c %s "${asset}")" \
#     -H "Content-Type: $(file -b --mime-type "${asset}")" \
#     --upload-file "${asset}" \
#     "${UPLOAD_URL}/${RELEASE_ID}/assets?name=${FILE_NAME}")"

#   if [ "${CODE}" -ne "201" ]; then
#     >&2 printf "\n\tERR: Uploading %s to Github release has failed\n" "${FILE_NAME}"
#     jq < "/tmp/${FILE_NAME}.json"
#     exit 1
#   fi
# done

# >&2 echo "All done."
