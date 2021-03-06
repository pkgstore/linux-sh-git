#!/usr/bin/bash

(( EUID == 0 )) &&
  { echo >&2 "This script should not be run as root!"; exit 1; }

# -------------------------------------------------------------------------------------------------------------------- #
# Get options.
# -------------------------------------------------------------------------------------------------------------------- #

OPTIND=1

while getopts "t:o:n:p:h" opt; do
  case ${opt} in
    t)
      token="${OPTARG}"
      ;;
    o)
      owner="${OPTARG}"
      ;;
    n)
      name="${OPTARG}"; IFS=';' read -ra name <<< "${name}"
      ;;
    p)
      topic="${OPTARG}"; IFS=';' read -ra topic <<< "${topic}"
      ;;
    h|*)
      echo "-t '[token]' -o '[owner]' -n '[name_1;name_2;name_3]' -p '[topic_1;topic_2;topic_3]'"
      exit 2
      ;;
  esac
done

shift $(( OPTIND - 1 ))

(( ! ${#name[@]} )) && exit 1

# -------------------------------------------------------------------------------------------------------------------- #
# -----------------------------------------------------< SCRIPT >----------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

curl="$( command -v curl )"
sleep="2"
topics=$( printf ',"%s"' "${topic[@]}" )

for i in "${name[@]}"; do
  echo "" && echo "--- Open: '${i}'"

  ${curl}                                                 \
  -X PUT                                                  \
  -H "Authorization: token ${token}"                      \
  -H "Accept: application/vnd.github.mercy-preview+json"  \
  "https://api.github.com/repos/${owner}/${i}/topics"     \
  -d @- << EOF
{
  "names": [ ${topics:1} ]
}
EOF

  echo "" && echo "--- Done: '${i}'" && echo ""

  sleep ${sleep}
done

# -------------------------------------------------------------------------------------------------------------------- #
# Exit.
# -------------------------------------------------------------------------------------------------------------------- #

exit 0
