#!/bin/bash
set -e

script_source="$(realpath "${BASH_SOURCE[0]}")"
root=$(echo "$script_source" | sed 's|\(/.*\)/java/.*|\1|')
module="$(dirname ${script_source#*/java/})"
module_source_dir="$(dirname "$script_source")"
relative_script_path="${script_source#$root/}"
source $root/shared-build-scripts/init.sh
cd $module_source_dir


$root/java/$module/.compile.sh "$root/.buildStepsDoneLastExecution"
# Create directory for compiled classes
mkdir -p $root/target/$module/classes/META-INF
printf "Manifest-Version: 1.0\nMain-Class: applications.directed_graph_build_systems_are_cool.DirectedGraphBuildSystemsAreCool\n" > $root/target/$module/classes/META-INF/MANIFEST.MF
mkdir -p $root/target/$module/bin
echo "Making $module distribution (jar)"
jar cfM $root/target/$module/bin/directed-graph-build-systems-are-cool.jar \
    -C $root/target/$module/classes . \
    -C $root/target/components/consonants/classes . \
    -C $root/target/components/fricatives/classes . \
    -C $root/target/components/glides/classes . \
    -C $root/target/components/nasal/classes . \
    -C $root/target/components/sonorants/classes . \
    -C $root/target/components/velar/classes . \
    -C $root/target/components/voiced/classes . \
    -C $root/target/components/voiceless/classes . \
    -C $root/target/components/vowelbase/classes . \
    -C $root/target/components/vowelbase/lib/release libvowelbase.so \
    -C $root/target/components/vowels/classes .

echo "To run this application, do:  java -Djava.library.path=. -jar ./target/applications/directed_graph_build_systems_are_cool/bin/directed-graph-build-systems-are-cool.jar"
