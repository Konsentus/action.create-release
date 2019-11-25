# Github Release create, update, and upload assets

Github Action to create, update, or add files to Github Releases.

## Usage

### Example Pipeline

Create a new folder `workflows` and create yaml file example `on-tag.yml` in the repository you are trying to use this release action. Copy below yaml code in this file.

```yaml
name: Bump Version and Tag
on:
  push:
    branches:
      - "master"
      - "sit"
      - "alpha"
      - "sandbox"
jobs:
  build-and-push:
    env:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    name: Bump and Tag
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@master
      - name: Bump and Tag
        id: bump_and_tag
        uses: konsentus/action.bump-version-and-tag@master
      - name: Release
        if: github.ref == 'refs/heads/master'
        uses: konsentus/action.create-release@master
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          previous_version_tag: ${{ steps.bump_and_tag.outputs.previous_version_tag }}
          new_version_tag: ${{ steps.bump_and_tag.outputs.new_version_tag }}
```
## Arguments

- `BASE_URL`: Github repository URL where release happen.
- `INPUT_NEW_VERSION_TAG`: New tag got from previous release.
- `RELEASE_NAME`: Name of new release.
- `INPUT_TOKEN`: Input token got from previous action to authorize to do release action.


## Outputs

- `Source code(zip)`: Zipped version for  source code files, and folders.
- `Source code(tar.gz)`: Compressed version for both files, and folders.
