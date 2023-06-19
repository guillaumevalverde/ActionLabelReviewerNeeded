#!/bin/bash
set -eu

if [[ -z "$GITHUB_TOKEN" ]]; then
  echo "Set the GITHUB_TOKEN env variable."
  exit 1
fi

if [[ -z "$GITHUB_EVENT_PATH" ]]; then
  echo "Set the GITHUB_EVENT_PATH env variable."
  exit 1
fi

API_HEADER="Accept: application/vnd.github.v3+json; application/vnd.github.antiope-preview+json"
AUTH_HEADER="Authorization: token ${GITHUB_TOKEN}"

action=$(jq --raw-output .action "$GITHUB_EVENT_PATH")
number=$(jq --raw-output .pull_request.number "$GITHUB_EVENT_PATH")
reviewers=$(jq --raw-output '.pull_request.requested_reviewers|map(."login")' "$GITHUB_EVENT_PATH")

listReviewerWithoutSpace=`echo ${reviewers} | tr -d '[:space:]'`                            

add_label() {
  curl -sSL \
    -H "Content-Type: application/json" \
    -H "${AUTH_HEADER}" \
    -H "${API_HEADER}" \
    -X $1 \
    -d '{"labels":["enhancement"]}' \
    "https://api.github.com/repos/${GITHUB_REPOSITORY}/issues/${number}/labels"
}

setNumberNeededReviewer() {
if [[ -z ${MANDATORY_REVIEWER_NUMBER+x} ]]; then
  numberReviewer=2
else
  numberReviewer=$MANDATORY_REVIEWER_NUMBER
fi
}

setUpLabel() {
  if [[ -z ${LABEL_FOR_REVIEWER_NEEDED+x} ]]; then
     labelToPost="REVIEWER NEEDED"
  else
    labelToPost="${LABEL_FOR_REVIEWER_NEEDED}"
  fi
}


setNumberNeededReviewer
setUpLabel
echo 'label to post:'$labelToPost
echo 'number of reviewer: '$numberReviewer', '${listReviewerWithoutSpace}

if [ "${#reviewers[@]}" -gt "${numberReviewer}" ] | [ "${#reviewers[@]}" -eq "${numberReviewer}" ]; then
  echo 'Pr has '${#reviewers[@]}' reviewers, and needs '${numberReviewer}'. All good!'
  #add_label 'POST' '${labelToPost}'
else
  echo 'Pr only has '${#reviewers[@]}' reviewer(s), but needs '${numberReviewer}'!'
  #add_label 'DELETE' '${labelToPost}'
fi

