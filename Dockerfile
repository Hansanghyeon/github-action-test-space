FROM ubuntu:latest

# fetch-gh-release-asset
RUN apt update
RUN apt -yq install rsync openssh-client ca-certificates curl wget jq

COPY fetch_github_asset.sh /fetch_github_asset.sh

ENTRYPOINT ["/fetch_github_asset.sh"]
