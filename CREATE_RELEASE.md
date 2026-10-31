# How to Create a GitHub Release

## Steps to Create Release v1.0.0

Since the code has been successfully pushed to GitHub, you can now create a release manually:

### Option 1: Using GitHub Web Interface (Recommended)

1. Go to: https://github.com/knight-dev01/TempSticky/releases/new

2. Fill in the release form:
   - **Tag version**: v1.0.0 (already created and pushed)
   - **Release title**: TempSticky v1.0.0 - Initial Release
   - **Description**: Copy content from RELEASE_NOTES.md

3. Check "Set as the latest release"

4. Click "Publish release"

### Option 2: Using GitHub CLI (if installed)

```bash
gh release create v1.0.0 \
  --title "TempSticky v1.0.0 - Initial Release" \
  --notes-file RELEASE_NOTES.md
```

### Option 3: Using Git command (Create draft release)

```bash
git tag v1.0.0
git push origin v1.0.0
```

Then go to the GitHub repository and convert the tag to a release.

## After Creating the Release

Users can download the project by:

1. **Clone the repository**:
   ```bash
   git clone https://github.com/knight-dev01/TempSticky.git
   cd TempSticky
   npm install
   npm start
   ```

2. **Download as ZIP**:
   - Click the "Code" button → "Download ZIP" on the repository page
   - Or from the release page, download the source code archive

## Quick Link

Direct release creation page: 
https://github.com/knight-dev01/TempSticky/releases/new?tag=v1.0.0&title=TempSticky%20v1.0.0%20-%20Initial%20Release
