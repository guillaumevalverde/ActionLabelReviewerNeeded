#!/bin/bash
set -eu

if [[ -z "$GITHUB_TOKEN" ]]; then
  echo "Set the GITHUB_TOKEN env variable."
  exit 1
fi

if [[ -z "$GITHUB_EVENT_NAME" ]]; then
  echo "Set the GITHUB_EVENT_NAME env variable."
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
assignees=$(jq --raw-output '.pull_request.assignees|map(."login")' "$GITHUB_EVENT_PATH")

listReviewerWithoutSpace=`echo ${reviewers} | tr -d '[:space:]'`
listAssigneesWithoutSpace=`echo ${assignees} | tr -d '[:space:]'`
                            

echo "remove first: "
echo "${listAssigneesWithoutSpace}"
echo "then assign: "
echo "${listReviewerWithoutSpace}"

update_review_request() {
  curl -sSL \
    -H "Content-Type: application/json" \
    -H "${AUTH_HEADER}" \
    -H "${API_HEADER}" \
    -X $1 \
    -d "{\"assignees\":$2}" \
    "https://api.github.com/repos/${GITHUB_REPOSITORY}/issues/${number}/assignees"
}

add_label() {
  curl -sSL \
    -H "Content-Type: application/json" \
    -H "${AUTH_HEADER}" \
    -H "${API_HEADER}" \
    -X $1 \
    -d '{"labels":["enhancement"]}'
    "https://api.github.com/repos/${GITHUB_REPOSITORY}/issues/${number}/labels"
}

update_review_request 'DELETE' ${listAssigneesWithoutSpace}
update_review_request 'POST' ${listReviewerWithoutSpace}
add_label 'POST' 'coucou'
