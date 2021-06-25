#!/usr/bin/bash

(( EUID == 0 )) &&
  { echo >&2 "This script should not be run as root!"; exit 1; }

# -------------------------------------------------------------------------------------------------------------------- #
# Get options.
# -------------------------------------------------------------------------------------------------------------------- #

OPTIND=1

while getopts "t:u:n:o:h" opt; do
  case ${opt} in
    t)
      token="${OPTARG}"
      ;;
    u)
      user="${OPTARG}"
      ;;
    o)
      org_url="${OPTARG}"
      ;;
    n)
      name="${OPTARG}"; IFS=';' read -ra name <<< "${name}"
      ;;
    h|*)
      echo "-t '[token]' -u '[user]' -o '[org_url] (e.g.: https://github.com/pkgstore)' -n '[name_1;name_2;name_3]'"
      exit 2
      ;;
  esac
done

shift $(( OPTIND - 1 ))

(( ! ${#name[@]} )) || [[ -z "${user}" ]] && exit 1

# -------------------------------------------------------------------------------------------------------------------- #
# -----------------------------------------------------< SCRIPT >----------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

curl="$( command -v curl )"
sleep="2"

for i in "${name[@]}"; do
  echo "" && echo "--- Open: '${i}'"

  ${curl}                                                                       \
  -X POST                                                                       \
  -H "Content-Type: application/json"                                           \
  "https://packagist.org/api/create-package?username=${user}&apiToken=${token}" \
  -d @- << EOF
{
  "repository": {
    "url": "${org_url}/${i}"
  }
}
EOF

  echo "" && echo "--- Done: '${i}'" && echo ""

  sleep ${sleep}
done

# -------------------------------------------------------------------------------------------------------------------- #
# Exit.
# -------------------------------------------------------------------------------------------------------------------- #

exit 0
