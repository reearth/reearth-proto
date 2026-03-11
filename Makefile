.PHONY: generate lint breaking tag-dev tag-prod push setup

# Install buf if not present
setup:
	@if ! command -v buf &> /dev/null; then \
		echo "Installing buf..."; \
		go install github.com/bufbuild/buf/cmd/buf@latest; \
		echo "✅ buf installed"; \
	else \
		echo "✅ buf already installed"; \
	fi

# Generate Go code from proto files
generate: setup
	@echo "Generating Go code from proto files..."
	@buf generate

# Lint proto files
lint: setup
	@echo "Linting proto files..."
	@buf lint

# Check for breaking changes against main branch
breaking: setup
	@echo "Checking for breaking changes..."
	@buf breaking --against '.git#branch=main'

# Tag development version with timestamp
tag-dev:
	@VERSION=$$(git tag -l "v[0-9]*.[0-9]*.[0-9]*" --sort=-version:refname | grep -v '\-' | head -1); \
	if [ -z "$${VERSION}" ]; then VERSION="v0.1.0"; fi; \
	TIMESTAMP=$$(date +%Y%m%d%H%M%S); \
	TAG="$${VERSION}-dev.$${TIMESTAMP}"; \
	echo "Creating development tag: $${TAG}"; \
	git tag -a "$${TAG}" -m "Development release $${TIMESTAMP}"; \
	git push origin "$${TAG}"; \
	echo "✅ Tagged: $${TAG}"

# Tag production version (requires VERSION parameter)
# Usage: make tag-prod VERSION=v1.2.3
tag-prod:
	@if [ -z "$(VERSION)" ]; then \
		echo "❌ Error: VERSION parameter required"; \
		echo "Usage: make tag-prod VERSION=v1.2.3"; \
		exit 1; \
	fi; \
	echo "Creating production tag: $(VERSION)"; \
	git tag -a "$(VERSION)" -m "Production release $(VERSION)"; \
	git push origin "$(VERSION)"; \
	echo "✅ Tagged: $(VERSION)"

# Push all commits and tags
push:
	@echo "Pushing commits and tags..."
	@git push origin main --tags
	@echo "✅ Pushed to origin"

# Show changes since last production tag
changes:
	@LAST_TAG=$$(git tag -l "v[0-9]*.[0-9]*.[0-9]*" --sort=-version:refname | grep -v '\-' | head -1); \
	if [ -z "$${LAST_TAG}" ]; then LAST_TAG="v0.1.0"; fi; \
	echo "Changes since last production tag ($${LAST_TAG}):"; \
	echo ""; \
	git log $${LAST_TAG}..HEAD --oneline --decorate

# List all production tags
list-tags:
	@echo "Production tags:"; \
	git tag -l "v[0-9]*.[0-9]*.[0-9]*" --sort=-version:refname | grep -v '\-' | head -10
