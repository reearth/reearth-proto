# Re:Earth Proto

Centralized Protocol Buffer definitions for Re:Earth internal APIs.

## Structure

```
cms/v1/          - CMS service proto definitions
visualizer/v1/   - Visualizer service proto definitions
```

## Versioning

### Development
```
v0.1.0-dev.20250706143000
```
- Used for development/staging
- Timestamp-based
- Auto-tagged on push to develop branch

### Production
```
v1.2.3
```
- Semantic versioning
- Manual tagging for releases
- MAJOR.MINOR.PATCH

## Usage

### As Go Module

```bash
go get github.com/reearth/reearth-proto@v1.0.0
```

### Import in Go

```go
import (
    cmspb "github.com/reearth/reearth-proto/gen/go/cms/v1"
    vispb "github.com/reearth/reearth-proto/gen/go/visualizer/v1"
)
```

## Development

```bash
# Generate code
make generate

# Lint proto files
make lint

# Check for breaking changes
make breaking

# Tag development version
make tag-dev

# Tag production version
make tag-prod VERSION=v1.1.0
```

## How Proto Files are Synced

Proto files are automatically synced from the OSS repositories:
- **Source**: `reearth/reearth-cms` and `reearth/reearth-visualizer` (public GitHub repos)
- **Frequency**: Every 6 hours via scheduled workflow
- **Manual sync**: Can be triggered via GitHub Actions UI
- **Auto-tagging**: When changes are detected, a new dev tag is created automatically

## For Service Maintainers

When updating proto files in CMS or Visualizer:

1. Make changes in your service's proto file
2. Test locally: `make grpc && go test ./...`
3. Push to main branch in CMS or Visualizer
4. Wait for auto-sync (or trigger manually in reearth-proto GitHub Actions)

## Production Releases

### When to Create Production Tags

- **After coordinated CMS/Visualizer releases** - When both services are stable
- **For breaking changes** - Major version bump when APIs change

### Creating Production Tags

**Option 1: Via GitHub UI (Recommended)**

1. Go to https://github.com/reearth/reearth-proto/actions/workflows/create-prod-tag.yml
2. Click "Run workflow" (green button)
3. Select version bump type:
   - **patch** (v1.0.0 → v1.0.1) - Bug fixes, no API changes
   - **minor** (v1.0.0 → v1.1.0) - New features, backward compatible
   - **major** (v1.0.0 → v2.0.0) - Breaking changes
   - **custom** - Enter your own version (e.g., v1.0.0)
4. Optionally add release notes
5. Click "Run workflow"
6. Done! The workflow will auto-calculate and create the tag

**Option 2: Via CLI**

```bash
# Review changes since last production release
make changes

# List existing production tags
make list-tags

# Create new production tag
make tag-prod VERSION=v1.0.0
```

**Option 3: Via gh CLI**

```bash
# Patch bump (v1.0.0 → v1.0.1)
gh workflow run create-prod-tag.yml \
  --repo reearth/reearth-proto \
  -f bump_type=patch \
  -f release_notes="Bug fixes"

# Minor bump (v1.0.0 → v1.1.0)
gh workflow run create-prod-tag.yml \
  --repo reearth/reearth-proto \
  -f bump_type=minor \
  -f release_notes="New features"

# Major bump (v1.0.0 → v2.0.0)
gh workflow run create-prod-tag.yml \
  --repo reearth/reearth-proto \
  -f bump_type=major \
  -f release_notes="Breaking changes"

# Custom version
gh workflow run create-prod-tag.yml \
  --repo reearth/reearth-proto \
  -f bump_type=custom \
  -f custom_version=v1.0.0
```

### Semantic Versioning

- **v1.0.0 → v2.0.0**: Breaking changes (field removed, RPC signature changed)
- **v1.0.0 → v1.1.0**: New features, backward compatible (new RPC added)
- **v1.0.0 → v1.0.1**: Bug fixes, no API changes

### Development vs Production Tags

- **Dev tags** (auto): `v0.1.0-dev.20251106190155` - Auto-created every 6 hours
- **Prod tags** (manual): `v1.0.0` - Manually created for stable releases
