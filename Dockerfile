FROM ubuntu:latest

RUN apt update
RUN apt -yq rsync openssh-client install ca-certificates curl wget jq

# fetch-gh-release-asset
ADD fetch_github_asset.sh /fetch_github_asset.sh
RUN chmod +x /fetch_github_asset.sh

ENTRYPOINT ["/fetch_github_asset.sh"]

# rsync-deploy
ADD rsync-deploy.sh /rsync-deploy.sh
RUN chmod +x /rsync-deploy.sh

ENTRYPOINT ["/rsync-deploy.sh"]
