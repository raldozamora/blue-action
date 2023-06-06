#!/bin/bash

set -e

if [[ -z "${TM_TOKEN_KEY}" ]]; then
  echo "Error: missing TM_TOKEN_KEY env variable"
  exit 1
fi

if [[ -z "${TM_API_URL}" ]]; then
  echo "Error: missing TM_API_URL env variable"
  exit 1
fi

# create snapshot with file, store result in json
FILE_S_CREATE="action_work_s_create.json"
npx bluemachinecli -t ${TM_TOKEN_KEY} snapshot create --repo-id ${1} --file ${2} --json-output ${FILE_S_CREATE}
if test -f "$FILE_S_CREATE"; then
    # analyze snapshot
    SNAPSHOT_ID=$(jq '.ID' $FILE_S_CREATE)
    echo "Snapshot Id : $SNAPSHOT_ID"
    FILE_S_ANA="action_work_s_ana.json"
    npx bluemachinecli -t ${TM_TOKEN_KEY} snapshot analyze --snapshot-id=${SNAPSHOT_ID} --json-output ${FILE_S_ANA}
    if test -f "$FILE_S_ANA"; then
        # create report for analysis
        ANA_ID=$(jq '.[0].id' $FILE_S_ANA)
        echo "Analysis ID : $ANA_ID"
        FILE_A_R_OUTPUT="action_work_ana_r.json"
        npx bluemachinecli -t ${TM_TOKEN_KEY} analyses report --analysis-id=${ANA_ID} --json-output ${FILE_A_R_OUTPUT}        
        if test -f "$FILE_A_R_OUTPUT"; then
            # get URL to download report file
            DOWNLOAD_URL=$(jq '.downloadURL' $FILE_A_R_OUTPUT)
            # remove double quotes from beginning and end of download url
            temp="${DOWNLOAD_URL%\"}"
            DOWNLOAD_URL="${temp#\"}"
            # download file
            echo "Downloading : $DOWNLOAD_URL"
            wget -O action_work_result_report.pdf ${DOWNLOAD_URL}
        fi   
    fi
fi
