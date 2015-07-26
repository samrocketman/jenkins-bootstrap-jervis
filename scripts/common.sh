#Created by Sam Gleske (https://github.com/samrocketman)
#Copyright 2015 Sam Gleske - https://github.com/samrocketman/jenkins-bootstrap-jervis
#Sun Jul 26 14:30:25 EDT 2015
#Ubuntu 14.04.2 LTS
#Linux 3.13.0-57-generic x86_64
#GNU bash, version 4.3.11(1)-release (x86_64-pc-linux-gnu)
#curl 7.35.0 (x86_64-pc-linux-gnu) libcurl/7.35.0 OpenSSL/1.0.1f zlib/1.2.8 libidn/1.28 librtmp/2.3

export CURL="${CURL:-curl}"

function curl_item_script() (
  set -euo pipefail
  #parse options
  jenkins='http://localhost:8080/scriptText'
  while [ ! -z "${1:-}" ]; do
    case $1 in
      -j|--jenkins)
          shift
          jenkins="$1"
          shift
        ;;
      -s|--script)
          shift
          script="$1"
          shift
        ;;
      -x|--xml-data)
          shift
          xml_data="$1"
          shift
        ;;
      -n|--item-name)
          shift
          item_name="$1"
          shift
        ;;
    esac
  done
  if [ -z "${item_name:-}" -o -z "${script:-}" -o -z "${xml_data:-}" -o -z "${item_name}" ]; then
    echo 'ERROR Missing an option for curl_item_script() function.'
    exit 1
  fi
  ${CURL} --data-urlencode "script=String itemName='${item_name}';String xmlData='''$(<${xml_data})''';$(<${script})" ${jenkins}
)
