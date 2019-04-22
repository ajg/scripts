#!/bin/sh
set -o errexit
set -o noclobber
set -o nounset
set -o pipefail

shopt -s extglob

case $(basename "$0") in
  # "m@${1}@" # "/${1//\//\\/}/"

  match)   perl -ne "print     if m#${1//#/\\#}#"       ;; # XXX: or filter, all/any, when
  unmatch) perl -ne "print unless m#${1//#/\\#}#"       ;; # XXX: or clash, except, none, mismatch
  replace) perl -0777 -pe "s#${1//#/\\#}#${2//#/\\#}#g" ;; # XXX: or sub/substitute
  erase)   perl -0777 -pe "s#${1//#/\\#}##g"            ;;
  unline)  perl -0777 -pe 's/\n//g'  ;;
# space)   perl -0777 -pe 's/\n/ /g' ;;
  chop)    perl -pe 'chop'  ;;
  chomp)   perl -pe 'chomp' ;; # 'chomp if eof'

# first)   head -n 1 ;;
# last)    tail -n 1 ;;

  print)   printf -- '%s'   "${*}" ;; # "${@}"
  println) printf -- '%s\n' "${*}" ;; # "${@}"
  quote)   printf -- '%q'   "${*}" ;; # "${@}"
  quoteln) printf -- '%q\n' "${*}" ;; # "${@}"

# empty)   printf ''   ;; # echo -n
# blank)   printf '\n' ;; # echo

# stdin)   cat        ;;
# stdout)  cat -      ;;
# stderr)  cat - 1>&2 ;;

  list)
    mtree -c -i -n -p "${1-.}" -k "${2-}" \
     | erase '\\\n\s*' \
     | unmatch '\.\.' \
     | unmatch '^$' \
     | unmatch '^/set\s+type=file' \
     | replace '(\s*)(\N+?)(\s*)type=dir' '$1$2/'
   # | unmatch '#'
    ;;
  quiet)
    if (( $# ));
      then 2>/dev/null "${@}"
      else 2>/dev/null cat -
    fi
    ;;
  silent) # or mute
    if (( $# ));
      then 1>/dev/null 2>/dev/null "${@}"
      else 1>/dev/null 2>/dev/null cat -
    fi
    ;;
  utility)
    if (( $# )) && [[ "${1}" != 'help' ]]; then
      "${@}" # $@
    else

      echo 'usage:'
      echo '  utility <name>  [arguments...]'
      echo '          match   <pattern>'
      echo '          clash   <pattern>'
      echo '          erase   <pattern>'
      echo '          replace <pattern> <replacement>'
      echo '          help'
      echo ''
      # TODO: remaining functions.
    fi
    ;;
  help)
    utility help
    ;;
  *)
    >&2 echo 'invalid utility'
    exit 1
    ;;
esac


