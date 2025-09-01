# Release Process

This document describes how to create releases for the fasd project.

## Automated Releases

The project uses GitHub Actions to automatically create releases when version tags are pushed.

### Creating a Release

1. **Update the version** in the fasd script if needed:
   ```bash
   # Edit the version in the fasd script (currently line 564)
   sed -i 's/echo "1\.0\.4"/echo "1.0.5"/' fasd
   ```

2. **Commit the version change** (if any):
   ```bash
   git add fasd
   git commit -m "Bump version to 1.0.5"
   ```

3. **Create and push a version tag**:
   ```bash
   git tag v1.0.5
   git push origin v1.0.5
   ```

4. **GitHub Actions will automatically**:
   - Create a new release on GitHub
   - Generate tar.gz and zip archives containing all project files
   - Upload the fasd script as a standalone asset
   - Include installation instructions in the release notes

### Release Assets

Each release includes:
- `fasd` - The main script file (for direct download)
- `fasd-{version}.tar.gz` - Complete project archive (gzipped tar)
- `fasd-{version}.zip` - Complete project archive (zip format)

### For Package Managers

The automated releases enable package managers like Homebrew to:
- Fetch the latest version using the GitHub Releases API
- Download verified source archives
- Access individual files like the main `fasd` script

## Manual Release (if needed)

If the automated process fails, you can create releases manually:

1. Go to [Releases page](https://github.com/whjvenyl/fasd/releases)
2. Click "Create a new release"
3. Choose or create a tag (e.g., `v1.0.5`)
4. Add release notes
5. Upload the necessary files

## Version Numbering

We follow semantic versioning (semver):
- Major version (x.0.0): Breaking changes
- Minor version (1.x.0): New features, backwards compatible
- Patch version (1.0.x): Bug fixes, backwards compatible