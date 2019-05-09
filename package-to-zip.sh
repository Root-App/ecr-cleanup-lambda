#!/bin/sh

YELLOW='\e[1;33m%-6s\e[m'

if [ ${#@} -ne 0 ] && [ "${@#"--help"}" = "" ]; then
  printf -- $YELLOW '''  Usage: ./package-to-zip.sh [optional filename]

  This shell file checks to make sure that you are on the master branch
  and it is current. Then it pulls the Python dependencies into the directory
  and creates a zip file inside the directory. The filename defaults to the format
  "ECRCleanup-yyyymmdd-hh-mm.zip", but you can pass a different one in as an argument.
  '''
  exit 0
fi


CURRENT_BRANCH=`git rev-parse --abbrev-ref HEAD`

RED='\033[0;31m'
NC='\033[0m'

if [ $CURRENT_BRANCH != "master" ]; then
  echo "${RED}ERROR:${NC} Incorrect branch. Please check out the master branch to bundle the lambda.\nExiting."
  exit 1
fi

git fetch origin

FILE_NAME=${1:-`date "+ECRCleanup-%Y%m%d-%H%M.zip"`}

CLEAN=`git status --porcelain` 
UP_TO_DATE=`git log HEAD..origin/master`
FAST_FORWARDABLE=`git status --ahead-behind | sed -n "/Your branch is behind 'origin\/master' by [0-9]* commits*, and can be fast-forwarded/p" | grep -c forwarded`

if [[ -z $CLEAN  && -z $UP_TO_DATE && $FAST_FORWARDABLE ]]; then
  git pull
else
    echo "${RED}ERROR:${NC} Please make sure your branch is clean and up-to-date.\nExiting."
  exit 1
fi

pip install -r requirements.txt -t .

zip -r $FILE_NAME .
