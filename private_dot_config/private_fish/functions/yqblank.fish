
function yqdiff;
  yq eval "$argv[1]" "$argv[2]" | diff -B "$argv[2]" - | patch "$argv[2]" -o - 
end
