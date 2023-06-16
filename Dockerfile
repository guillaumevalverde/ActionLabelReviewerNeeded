FROM debian:buster

LABEL "com.github.actions.name"="Assignee to reviewer"
LABEL "com.github.actions.description"="Automatically create review requests based on assignees"
LABEL "com.github.actions.icon"="arrow-up-right"
LABEL "com.github.actions.color"="gray-dark"

LABEL version="1.0.4"
LABEL repository="http://github.com/pullreminders/ActionLabelReviewerNeeded"
LABEL homepage="http://github.com/pullreminders/ActionLabelReviewerNeeded"
LABEL maintainer="Guillaume Valverde <guillaume.valverde@gmail.com>"

RUN apt-get update && apt-get install -y \
    curl \
    jq

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
