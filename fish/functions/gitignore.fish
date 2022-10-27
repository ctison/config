function gitignore -a FILEPATH
  if test -z "$FILEPATH"
    set -f FILEPATH .gitignore
  end
  cat $FILEPATH | rg -v -e '^[\s#]' -e '^$' | string join ,
end
