#!/bin/bash
# ============================================
# Pre-Release Build & Validation Script
# ============================================
# Combines Gradle build and release validation in one step.
# Usage: ./pre-release.sh
# Note: Run from project root or any subdirectory inside the repo.
#
# This script:
# 1. Builds the plugin using Gradle (./gradlew buildPlugin)
# 2. Validates the generated artifacts (JAR, ZIP, contents)
# 3. Reports exact generated artifact filenames
# 4. Streams all output to the terminal and saves it to a log file
#
# Exit codes:
#  0 = BUILD SUCCESS + VALIDATION PASS
#  1 = BUILD FAILED
#  2 = VALIDATION FAILED
# 64 = INVALID USAGE
# ============================================

set -uo pipefail

usage() {
  cat <<'EOF'
Usage: ./pre-release.sh

Builds the plugin with Gradle, validates the generated artifacts, and writes
the full terminal output to:
  - build/reports/pre-release/latest.log
  - build/reports/pre-release/pre-release-YYYYMMDD-HHMMSS.log

Options:
  -h, --help   Show this help and exit.

This script accepts no positional arguments.
EOF
}

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

LOG_DIR="build/reports/pre-release"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
LOG_LATEST="$LOG_DIR/latest.log"
LOG_ARCHIVE="$LOG_DIR/pre-release-$TIMESTAMP.log"
mkdir -p "$LOG_DIR"

# Remove legacy pre-release.log files from older script versions.
rm -f "$LOG_DIR/pre-release.log" "$LOG_DIR"/pre-release.log.*

if [ "$#" -eq 1 ] && { [ "$1" = "-h" ] || [ "$1" = "--help" ]; }; then
  usage
  exit 0
fi

exec > >(tee "$LOG_LATEST" "$LOG_ARCHIVE") 2>&1

if [ "$#" -ne 0 ]; then
  echo "Error: unexpected argument(s): $*"
  echo
  usage
  echo
  echo "Latest log: $LOG_LATEST"
  echo "Archived log: $LOG_ARCHIVE"
  exit 64
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TTY_DEVICE=''
if [ -w /dev/tty ]; then
  TTY_DEVICE='/dev/tty'
fi

print_progress() {
  local current=$1
  local total=$2
  local bar_length=40
  local filled=$(( (current * bar_length) / total ))
  local empty=$(( bar_length - filled ))

  if [ -n "$TTY_DEVICE" ]; then
    printf '\rProgress: ' > "$TTY_DEVICE"
    if [ "$filled" -gt 0 ]; then
      printf '%0.s█' $(seq 1 "$filled") > "$TTY_DEVICE"
    fi
    if [ "$empty" -gt 0 ]; then
      printf '%0.s░' $(seq 1 "$empty") > "$TTY_DEVICE"
    fi
    printf ' %d/%d' "$current" "$total" > "$TTY_DEVICE"
  fi
}

finish_progress() {
  if [ -n "$TTY_DEVICE" ]; then
    printf '\n' > "$TTY_DEVICE"
  fi
}

find_release_jar() {
  find build/libs -maxdepth 1 -type f -name '*.jar' \
    ! -name '*-base.jar' \
    ! -name '*-instrumented.jar' \
    ! -name '*-searchableOptions.jar' \
    2>/dev/null | sort | head -n 1
}

find_release_zip() {
  find build/distributions -maxdepth 1 -type f -name '*.zip' 2>/dev/null | sort | head -n 1
}

find_ide_artifact_jar() {
  if [ -f 'out/artifacts/nightshade_jar/nightshade.jar' ]; then
    printf '%s\n' 'out/artifacts/nightshade_jar/nightshade.jar'
  fi
}

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}Pre-Release Build & Validation${NC}"
echo -e "${BLUE}============================================${NC}"
echo "Working directory: $SCRIPT_DIR"
echo "Latest log: $LOG_LATEST"
echo "Archived log: $LOG_ARCHIVE"
echo

echo -e "${YELLOW}[Phase 1/2]${NC} Building plugin with Gradle..."
echo

if ./gradlew buildPlugin; then
  echo -e "${GREEN}✓ Gradle build completed successfully${NC}"
  echo
else
  echo -e "${RED}✗ Gradle build failed${NC}"
  echo -e "${RED}Exit code: 1${NC}"
  echo "Latest log: $LOG_LATEST"
  echo "Archived log: $LOG_ARCHIVE"
  exit 1
fi

echo -e "${YELLOW}[Phase 2/2]${NC} Validating release artifacts..."
echo

GRADLE_JAR="$(find_release_jar)"
IDE_JAR="$(find_ide_artifact_jar)"
ZIP_FILE="$(find_release_zip)"
VALIDATION_JAR=''
if [ -n "$GRADLE_JAR" ]; then
  VALIDATION_JAR="$GRADLE_JAR"
elif [ -n "$IDE_JAR" ]; then
  VALIDATION_JAR="$IDE_JAR"
fi

JAR_LISTING=''
if [ -n "$VALIDATION_JAR" ]; then
  JAR_LISTING="$(jar tf "$VALIDATION_JAR" 2>/dev/null)"
fi

c1=0
[ -n "$VALIDATION_JAR" ] && c1=1
print_progress 1 5

c2=0
if printf '%s\n' "$JAR_LISTING" | grep -Fxq 'META-INF/plugin.xml'; then
  c2=1
fi
print_progress 2 5

c3=0
if printf '%s\n' "$JAR_LISTING" | grep -Fxq 'theme/nightshade.theme.json' && printf '%s\n' "$JAR_LISTING" | grep -Fxq 'theme/nightshade.xml'; then
  c3=1
fi
print_progress 3 5

c4=0
if printf '%s\n' "$JAR_LISTING" | grep -Fxq 'META-INF/pluginIcon.svg' && printf '%s\n' "$JAR_LISTING" | grep -Eq '^images/'; then
  c4=1
fi
print_progress 4 5

c5=0
[ -n "$ZIP_FILE" ] && c5=1
print_progress 5 5
finish_progress
echo

n=('1 JAR exists' '2 plugin.xml' '3 theme files' '4 icon+images' '5 ZIP exists')
v=("$c1" "$c2" "$c3" "$c4" "$c5")

for i in 0 1 2 3 4; do
  [ "${v[$i]}" -eq 1 ] && s="${GREEN}PASS${NC}" || s="${RED}FAIL${NC}"
  echo -e "${n[$i]}: $s"
done

echo
echo -e "${BLUE}Artifact Summary${NC}"
echo "  Gradle JAR: ${GRADLE_JAR:-not found}"
echo "  IDE artifact JAR: ${IDE_JAR:-not found}"
echo "  Release ZIP: ${ZIP_FILE:-not found}"
echo "  Validation source JAR: ${VALIDATION_JAR:-not found}"
echo "  Latest log: $LOG_LATEST"
echo "  Archived log: $LOG_ARCHIVE"
echo

if [ $((c1 + c2 + c3 + c4 + c5)) -eq 5 ]; then
  echo -e "${GREEN}============================================${NC}"
  echo -e "${GREEN}✓ OVERALL: PASS${NC}"
  echo -e "${GREEN}Plugin is ready for release!${NC}"
  echo -e "${GREEN}============================================${NC}"
  exit 0
else
  echo -e "${RED}============================================${NC}"
  echo -e "${RED}✗ OVERALL: FAIL${NC}"
  echo -e "${RED}Please fix validation errors before release.${NC}"
  echo -e "${RED}============================================${NC}"
  exit 2
fi

