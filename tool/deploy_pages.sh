#!/usr/bin/env bash
# Build Flutter web and sync into docs/ for GitHub Pages.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

VERSION="$(awk '/^version:/ {print $2; exit}' pubspec.yaml)"
if [[ -z "$VERSION" ]]; then
  echo "Could not read version from pubspec.yaml" >&2
  exit 1
fi

echo "Building web (base-href=/WorkoutBell/, cache-bust=$VERSION)..."
flutter build web --release --base-href /WorkoutBell/

# Stamp pubspec version into asset URLs so browsers fetch fresh entry files.
# Also drop empty buildConfig entries that can confuse some mobile loaders.
python3 - "$VERSION" <<'PY'
import pathlib, re, sys
version = sys.argv[1]
index = pathlib.Path("build/web/index.html")
text = index.read_text()
text = text.replace("CACHE_BUST", version)
# Prefer no service worker registration if a bootstrap file still includes it.
text = re.sub(
    r"serviceWorkerSettings\s*:\s*\{.*?\},?",
    "",
    text,
    flags=re.S,
)
text = text.replace(',{}]', ']')
text = text.replace(', {}]', ']')
index.write_text(text)
print(f"Stamped CACHE_BUST -> {version} in build/web/index.html")
PY

rsync -a --delete --exclude screenshots --exclude '.git' build/web/ docs/
touch docs/.nojekyll

echo "docs/ updated. Commit and push to publish Pages."
