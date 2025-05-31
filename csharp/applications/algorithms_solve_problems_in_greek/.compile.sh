#!/bin/bash
set -e

script_source="$(realpath "${BASH_SOURCE[0]}")"
root=$(echo "$script_source" | sed 's|\(/.*\)/csharp/.*|\1|')
module="$(dirname ${script_source#*/csharp/})"
module_source_dir="$(dirname "$script_source")"
relative_script_path="${script_source#$root/}"
source $root/shared-build-scripts/init.sh
cd $module_source_dir

deps=(
  "module:csharp/components/greek"
  "module:csharp/components/vowelbase"
)

# Visit compile-time deps and invoke their .compile.sh scripts
for dep in "${deps[@]}"; do "$root/${dep#module:}/.compile.sh" "$root/.buildStepsDoneLastExecution"; done

# Create directory for compiled binaries
mkdir -p $root/target/$module/bin

# Build the reference list from deps
references=()
for dep in "${deps[@]}"; do
  dep_path="${dep#module:csharp/}"
  dep_name=$(basename "$dep_path")
  references+=("-reference:$root/target/$dep_path/bin/components_$dep_name.dll")
done

source "$root/shared-build-scripts/calc-dotnet-version-vars.sh"

REF=~/.dotnet/packs/Microsoft.NETCore.App.Ref/$DOTNET_FRAMEWORK_VER/ref/net10.0/

echo "$relative_script_path: compiling C# component with Roslyn"

mkdir -p "$root/target/$module/bin"
dotnet exec ~/.dotnet/sdk/$DOTNET_SDK_VER/Roslyn/bincore/csc.dll \
    -nologo \
    -langversion:latest \
    -out:"$root/target/$module/bin/AlgorithmsSolveProblemsInGreek.dll" \
    -target:library \
    -recurse:"$module_source_dir/*.cs" \
    -reference:$HOME/.dotnet/shared/Microsoft.NETCore.App/$DOTNET_FRAMEWORK_VER/System.Private.CoreLib.dll \
    -reference:$HOME/.dotnet/shared/Microsoft.NETCore.App/$DOTNET_FRAMEWORK_VER/System.Console.dll \
    -reference:$REF/System.Runtime.dll \
    -reference:$REF/netstandard.dll \
    -reference:"$HOME/.dotnet/shared/Microsoft.NETCore.App/$DOTNET_FRAMEWORK_VER/System.Runtime.dll" \
    -reference:"$HOME/.dotnet/shared/Microsoft.NETCore.App/$DOTNET_FRAMEWORK_VER/mscorlib.dll" \
    "${references[@]}"