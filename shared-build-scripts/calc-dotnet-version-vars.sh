if [ ! -f "$root/target/dotnet-framework-version.txt" ]; then
  dotnet run $root/shared-build-scripts/determine-dotnet-framework-version.cs \
    > "$root/target/dotnet-framework-version.txt"

  dotnet --version  > "$root/target/dotnet-sdk-version.txt"
fi

DOTNET_FRAMEWORK_VER="$(<"$root/target/dotnet-framework-version.txt")"
DOTNET_SDK_VER="$(<"$root/target/dotnet-sdk-version.txt")"