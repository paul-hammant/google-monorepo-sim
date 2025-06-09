#!/bin/bash
set -eo pipefail

script_source="$(realpath "${BASH_SOURCE[0]}")"
root=$(echo "$script_source" | sed 's|\(/.*\)/java/.*|\1|')
module="$(dirname ${script_source#*/java/})"
module_source_dir="$(dirname "$script_source")"
relative_script_path="${script_source#$root/}"
source $root/shared-build-scripts/init.sh
cd $module_source_dir

# Sibling dep
./.compile.sh "$root/.buildStepsDoneLastExecution"

# Create directory for compiled classes
mkdir -p $root/target/$module/classes/META-INF
printf "Manifest-Version: 1.0\nMain-Class: applications.monorepos_rule.MonoreposRule\n" > $root/target/$module/classes/META-INF/MANIFEST.MF
mkdir -p $root/target/$module/bin
echo "Making $module distribution jar"

jar_args=(-C "$root/target/$module/classes" .)

while IFS= read -r line; do
  [ -n "$line" ] && jar_args+=(-C "$line" .)
done < "$root/target/$module/jvm_classpath_deps_including_transitive"

while IFS= read -r line; do
  dir=$(dirname "$line")
  file=$(basename "$line")
  [ -n "$line" ] && jar_args+=(-C "$dir" "$file")
done < "$root/target/$module/ldlibdeps"

jar cfM "$root/target/$module/bin/monorepos-rule.jar" "${jar_args[@]}"

echo "To run this application, do:  java -Djava.library.path=. -jar ./target/applications/monorepos_rule/bin/monorepos-rule.jar"
