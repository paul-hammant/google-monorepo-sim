#!/bin/bash
set -e

script_source="$(realpath "${BASH_SOURCE[0]}")"
root=$(echo "$script_source" | sed 's|\(/.*\)/csharptests/.*|\1|')
module="$(dirname ${script_source#*/csharptests/})"
module_source_dir="$(dirname "$script_source")"
relative_script_path="${script_source#$root/}"
source $root/shared-build-scripts/tests-init.sh
cd $module_source_dir

deps=(
  "module:csharp/components/greek"
)

# Visit compile-time deps and invoke their .compile.sh scripts
for dep in "${deps[@]}"; do "$root/${dep#module:}/.compile.sh" "$root/.buildStepsDoneLastExecution"; done

# Define additional binary dependencies (external libraries like nunit)
libdeps=(
  "lib:csharp/shouldly/Shouldly.dll"
)

# Build LIBS_CLASSPATH:
# - Add paths to required dlls from lib/
LIBS_CLASSPATH=$(
  {
    for libdep in "${libdeps[@]}"; do
      echo "$root/libs/${libdep#lib:}" 2>/dev/null
    done
  } | sort -u | paste -sd ":" -
)

source "$root/shared-build-scripts/calc-dotnet-version-vars.sh"

OTHER_RUNTIME_PATH="~/.dotnet/shared/Microsoft.NETCore.App/$DOTNET_FRAMEWORK_VER/$DOTNET_FRAMEWORK_VER"
REF=~/.dotnet/packs/Microsoft.NETCore.App.Ref/$DOTNET_FRAMEWORK_VER/ref/net10.0/
OTHER_REF=~/.dotnet/packs/Microsoft.NETCore.App.Ref/$DOTNET_FRAMEWORK_VER/ref/net10.0/

# Run the tests using dotnet run
echo "$relative_script_path: running C# tests with dotnet run <srcfile>"

dotnet run GreekTests.cs
#dotnet run QuickTests.cs
# TODO: add package dep for compnents/greek

