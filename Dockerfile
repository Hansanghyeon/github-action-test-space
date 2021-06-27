FROM ubuntu:latest

RUN apt update
# fetch-gh-release-asset
RUN apt -yq install ca-certificates curl wget jq

ADD fetch_github_asset.sh /fetch_github_asset.sh
RUN chmod +x /fetch_github_asset.sh

ENTRYPOINT ["/fetch_github_asset.sh"]

# rsync-deploy
RUN apt -yq rsync openssh-client

ADD rsync-deploy.sh /rsync-deploy.sh
RUN chmod +x /rsync-deploy.sh

ENTRYPOINT ["/rsync-deploy.sh"]

