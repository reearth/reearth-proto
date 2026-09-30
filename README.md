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

## Where Proto Files Come From

The two services are set up differently. The scheduled sync workflow is
currently **disabled** - see the note at the top of
`.github/workflows/sync-from-oss.yml`.

### Visualizer - this repo is the source of truth

`reearth-visualizer` deleted its own proto in
[reearth-visualizer#2189](https://github.com/reearth/reearth-visualizer/pull/2189)
and depends on this module instead. Edit `visualizer/v1/visualizer.proto` here.

### CMS - still owned upstream, mirrored here by hand

`reearth-cms` owns `server/schemas/internalapi/v1/schema.proto` and generates
its own Go code from it; it does not consume this module. The copy in
`cms/v1/cms.proto` exists for `reearth-dashboard`, which imports
`reearth-proto/gen/go/cms/v1`.

That means the dashboard's client stubs and the CMS server's stubs are built
from two separate copies of the same schema. A mismatch does not break any
build - it shows up at runtime as empty fields or a missing RPC. When CMS
changes its proto, update `cms/v1/cms.proto` here to match, run
`make generate`, and cut a new tag.

> **Open question:** should `reearth-cms` depend on this module the way
> visualizer does? That would remove the duplicate copy entirely.

## For Service Maintainers

**Visualizer schema change:**

1. Edit `visualizer/v1/visualizer.proto` in this repo
2. `make generate` and commit `gen/` alongside it
3. `make breaking` to confirm wire compatibility
4. Merge, then tag (`make tag-prod VERSION=vX.Y.Z` or the GitHub Actions workflow)
5. Bump the `reearth-proto` version in the consuming services

**CMS schema change:**

1. Make the change in `reearth-cms` as usual
2. Copy it into `cms/v1/cms.proto` here, keeping this repo's `go_package` line
3. Then follow steps 2-5 above

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
