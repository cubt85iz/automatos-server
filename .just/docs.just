# Build website
[group('Development')]
build:
  @pushd docs &> /dev/null && \
  hugo --gc --minify && \
  popd &> /dev/null

# Lint content
[group('Development')]
lint:
  @pushd docs &> /dev/null && \
  podman run -v ./content:/workdir:z,ro --rm ghcr.io/igorshubovych/markdownlint-cli:latest "**/*.md" && \
  popd &> /dev/null

# Publish article
[group('Development')]
publish *files:
  #!/usr/bin/env bash

  set -euo pipefail

  # Analyze front matter for yaml files for invalid data.
  if verify-file-links "$file"; then
    if verify-file-taxonomies "$file"; then
      for file in $files; do
        sed -i "s|draft: true|draft: false|" "$file"
      done
    fi
  fi

  exit $overall_status

# Serve website
[group('Development')]
serve:
  @pushd docs &> /dev/null && \
  hugo serve --watch -D && \
  popd &> /dev/null

[private]
setup_hooks:
  # TODO: Reassign hooks folder
  exit

# Verify all links in file
[private]
[group('Development')]
verify-file-links file:
  #!/usr/bin/env bash

  set -euo pipefail

  podman run -v {{ file }}:/tmp/file:z,ro --rm ghcr.io/tcort/markdown-link-check:stable --quiet "/tmp/file"

# Verify all links in content
[private]
[group('Development')]
verify-links:
  #!/usr/bin/env bash

  set -euo pipefail

  overall_status=0
  for file in ./content/**/*.md; do
    if ! verify-file-links "$file"; then
      overall_status=1
    fi
  done

  exit $overall_status

# Verify content
[group('Development')]
verify: verify-links
