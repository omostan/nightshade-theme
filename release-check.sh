#!/bin/bash
# ============================================
# Before running, ensure you have built the plugin with Gradle (./gradlew build or ./gradlew buildPlugin) to generate the JAR and ZIP files.
# Release Validation Checker
# Verifies that plugin artifacts are ready for release:
# 1. JAR exists in Gradle output
# 2. JAR contains plugin.xml
# 3. JAR contains theme files
# 4. JAR contains icon and images
# 5. ZIP exists in Gradle distributions
# Usage: ./release-check.sh
# Note: Run from project root after building with Gradle
# Checks for JAR in build/libs or out/artifacts, then validates contents and ZIP existence
# Outputs PASS/FAIL for each check and overall status
# 0 = FAIL, 1 = PASS
# ============================================
# Example output:
# Progress: ████████████████░░░░░░░░░░░░░░░░░░░░ 2/5
# 1 JAR exists: PASS
# 2 plugin.xml: PASS
# 3 theme files: PASS
# 4 icon+images: PASS
# 5 ZIP exists: PASS
# OVERALL: PASS

# Progress bar function
print_progress() {
  local current=$1
  local total=$2
  local bar_length=40
  local filled=$(( (current * bar_length) / total ))
  local empty=$(( bar_length - filled ))

  printf '\rProgress: '
  printf '%0.s█' $(seq 1 $filled)
  printf '%0.s░' $(seq 1 $empty)
  printf ' %d/%d' "$current" "$total"
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

gradle_jar="$(find_release_jar)"
ide_jar="$(find_ide_artifact_jar)"
j=''
[ -n "$gradle_jar" ] && j="$gradle_jar" || ([ -n "$ide_jar" ] && j="$ide_jar")
z="$(find_release_zip)"
l=''
[ -n "$j" ] && l="$(jar tf "$j" 2>/dev/null)"

c1=$([ -f "$j" ] && echo 1 || echo 0)
print_progress 1 5

printf '%s\n' "$l" | grep -Fxq 'META-INF/plugin.xml'
c2=$([ $? -eq 0 ] && echo 1 || echo 0)
print_progress 2 5

printf '%s\n' "$l" | grep -Fxq 'theme/nightshade.theme.json' && printf '%s\n' "$l" | grep -Fxq 'theme/nightshade.xml'
c3=$([ $? -eq 0 ] && echo 1 || echo 0)
print_progress 3 5

printf '%s\n' "$l" | grep -Fxq 'META-INF/pluginIcon.svg' && printf '%s\n' "$l" | grep -Eq '^images/'
c4=$([ $? -eq 0 ] && echo 1 || echo 0)
print_progress 4 5

c5=$([ -n "$z" ] && echo 1 || echo 0)
print_progress 5 5
echo ''

n=('1 JAR exists' '2 plugin.xml' '3 theme files' '4 icon+images' '5 ZIP exists')
v=("$c1" "$c2" "$c3" "$c4" "$c5")

for i in 0 1 2 3 4; do
  [ "${v[$i]}" -eq 1 ] && s=PASS || s=FAIL
  echo "${n[$i]}: $s"
done

[ -n "$gradle_jar" ] && echo "Gradle JAR: $gradle_jar" || echo 'Gradle JAR: not found'
[ -n "$ide_jar" ] && echo "IDE artifact JAR: $ide_jar" || echo 'IDE artifact JAR: not found'
[ -n "$z" ] && echo "Release ZIP: $z" || echo 'Release ZIP: not found'
[ -n "$j" ] && echo "Validation source JAR: $j" || echo 'Validation source JAR: not found'

[ $((c1+c2+c3+c4+c5)) -eq 5 ] && echo 'OVERALL: PASS' || echo 'OVERALL: FAIL'

