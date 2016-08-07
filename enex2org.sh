#!/bin/bash
set -e

## Converts Evernote export xml format (*.enex) to org mode format.
## Outputs a single org mode file.
## Usage: enex2org.sh [options] FILE1 [FILE2 ...]
##
##       [-h     | --help]     Print this help message

BASE=$(cd $(dirname $0); pwd -P)

usage() {
   echo "$(grep "^## " "${BASH_SOURCE[0]}" | cut -c 4-)"
   exit 0
}

error() {
   cat <<< "$@" 1>&2
   exit 1
}

[[ $# == 0 ]] && usage

# Transform long options to short ones
for arg in "$@"; do
  shift
  case "$arg" in
    "--help") set -- "$@" "-h" ;;
    *)        set -- "$@" "$arg"
  esac
done
# Parse short options
OPTIND=1
while getopts "hf:b:" opt
do
  case "$opt" in
    "h") usage; exit 0 ;;
    "?") usage >&2; exit 1 ;;
    ":") error "Option -$OPTARG requires an argument.";;
  esac
done
shift $(expr $OPTIND - 1) # remove options from positional parameters


ARGS=$@

#Notes without timestamps
#xml-find "$ARGS" -name note -exec xml-printf '* %s \n' {-} ://en-export/note/title \; \
  #-exec bash -c 'xml-strings --no-squeeze {-} :/en-export/note/content | xml-strings --no-squeeze ' \; \
  #-exec xml-printf '\n' \;

#Notes with timestamps (not yet in orgmode format)
#xml-find "$ARGS" -name note -exec xml-printf '* %s \n\n' {-} ://en-export/note/title \; \
  #-exec bash -c 'xml-printf ":PROPERTIES:\n:created: [%s]\n:updated: [%s]\n:END:\n\n" {-} ://en-export/note/created ://en-export/note/updated ' \; \
  #-exec bash -c 'xml-strings --no-squeeze {-} :/en-export/note/content | xml-strings --no-squeeze ' \; \
  #-exec xml-printf '\n' \;

#Notes with timestamps in orgmode format
xml-find "$ARGS" -name note -exec xml-printf '* %s \n\n' {-} ://en-export/note/title \; \
  -exec echo ':PROPERTIES:' \; \
  -exec bash -c 'echo -n ":created: " && (xml-strings {-} ://en-export/note/created | xargs date -jf "%Y%m%dT%H%M%SZ" "+[%Y-%m-%d %a %H:%M]" )' \; \
  -exec bash -c 'echo -n ":updated: " && (xml-strings {-} ://en-export/note/updated | xargs date -jf "%Y%m%dT%H%M%SZ" "+[%Y-%m-%d %a %H:%M]" )' \; \
  -exec echo ':END:' \; \
  -exec bash -c 'xml-strings --no-squeeze {-} :/en-export/note/content | xml-strings --no-squeeze ' \; \
  -exec xml-printf '\n' \;

