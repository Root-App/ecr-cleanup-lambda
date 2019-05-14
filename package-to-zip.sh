#!/bin/sh

YELLOW='\e[1;33m%-6s\e[m'

if [ ${#@} -ne 0 ] && [ "${@#"--help"}" = "" ]; then
  printf -- $YELLOW '''  Usage: ./package-to-zip.sh [optional filename]

  This shell file checks to make sure that your branch is clean and current with the remote.
  Then it pulls the Python dependencies into the directory
  and creates a zip file inside the directory. The filename defaults to the format
  "ECRCleanup-yyyymmdd-hh-mm.zip", but you can pass a different one in as an argument.
  '''
  exit 0
fi

RED='\033[0;31m'
NC='\033[0m'

FILE_NAME=${1:-`date "+ECRCleanup-%Y%m%d-%H%M.zip"`}
CURRENT_BRANCH=`git rev-parse --abbrev-ref HEAD`

git fetch origin

NOT_CLEAN=`git status --porcelain`
NOT_UP_TO_DATE=`git log HEAD..origin/$CURRENT_BRANCH`

if [[ $NOT_CLEAN || $NOT_UP_TO_DATE ]]; then
  echo "${RED}ERROR:${NC} Please make sure your branch is clean and up-to-date.\nExiting."
  exit 1
fi

pip install -r requirements.txt -t .

zip -r $FILE_NAME .
