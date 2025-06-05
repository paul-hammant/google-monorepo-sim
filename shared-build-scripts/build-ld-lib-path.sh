LD_LIB_PATH=()

while IFS= read -r line; do
  dir=$(dirname "$line")
  [ -n "$line" ] && LD_LIB_PATH+=("$dir")
done < "$root/target/$module/ldlibdeps"
