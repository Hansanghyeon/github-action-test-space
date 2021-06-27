FROM ubuntu:latest

RUN apt update
RUN apt -yq install rsync openssh-client ca-certificates curl wget jq

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
