#!/bin/bash

if [[ -z "$INPUT_FILE" ]]; then
  echo "Missing file input in the action"
  exit 1
fi

if [[ -z "$GITHUB_REPOSITORY" ]]; then
  echo "Missing GITHUB_REPOSITORY env variable"
  exit 1
fi

REPO=$GITHUB_REPOSITORY
if ! [[ -z ${INPUT_REPO} ]]; then
  REPO=$INPUT_REPO
fi

# Optional target file path
TARGET=$INPUT_FILE
if ! [[ -z ${INPUT_TARGET} ]]; then
  TARGET=$INPUT_TARGET
fi

# Optional personal access token for external repository
TOKEN=$GITHUB_TOKEN
if ! [[ -z ${INPUT_TOKEN} ]]; then
  TOKEN=$INPUT_TOKEN
fi

API_URL="https://api.github.com/repos/$REPO"
RELEASE_DATA=$(curl -H "Authorization: token $TOKEN" $API_URL/releases/${INPUT_VERSION})
MESSAGE=$(echo $RELEASE_DATA | jq -r ".message")

if [[ "$MESSAGE" == "Not Found" ]]; then
  echo "[!] Release asset not found"
  echo "Release data: $RELEASE_DATA"
  echo "-----"
  echo "repo: $REPO"
  echo "asset: $INPUT_FILE"
  echo "target: $TARGET"
  echo "version: $INPUT_VERSION"
  exit 1
fi

ASSET_ID=$(echo $RELEASE_DATA | jq -r ".assets | map(select(.name == \"${INPUT_FILE}\"))[0].id")
TAG_VERSION=$(echo $RELEASE_DATA | jq -r ".tag_name" | sed -e "s/^v//" | sed -e "s/^v.//")
RELEASE_NAME=$(echo $RELEASE_DATA | jq -r ".name")
RELEASE_BODY=$(echo $RELEASE_DATA | jq -r ".body")

if [[ -z "$ASSET_ID" ]]; then
  echo "Could not find asset id"
  exit 1
fi

curl \
  -J \
  -L \
  -H "Accept: application/octet-stream" \
  -H "Authorization: token $TOKEN" \
  "$API_URL/releases/assets/$ASSET_ID" \
  --create-dirs \
  -o ${TARGET}

echo "::set-output name=version::$TAG_VERSION"
echo "::set-output name=name::$RELEASE_NAME"
echo "::set-output name=body::$RELEASE_BODY"


##################################################
## Release 다운로드 받은 파일 압축 해제
##################################################
mkdir @sync
tar xvf ${TARGET} -C ./@sync
rm ${TARGET}

##################################################
## rsync
##################################################
DEPLOY_KEY=$INPUT_DEPLOY_KEY
if ! [[ -z ${INPUT_DEPLOY_KEY} ]]; then
  DEPLOY_KEY=$DEPLOY_KEY
fi

USERNAME=$INPUT_USERNAME
if ! [[ -z ${INPUT_USERNAME} ]]; then
  USERNAME=$INPUT_USERNAME
fi

SERVER_IP=$INPUT_SERVER_IP
if ! [[ -z ${INPUT_SERVER_IP} ]]; then
  SERVER_IP=$INPUT_SERVER_IP
fi

SERVER_DESTINATION=$INPUT_SERVER_DESTINATION
if ! [[ -z ${INPUT_SERVER_DESTINATION} ]]; then
  SERVER_DESTINATION=$INPUT_SERVER_DESTINATION
fi

ARGS=$INPUT_ARGS
if ! [[ -z ${INPUT_ARGS} ]]; then
  ARGS=$INPUT_ARGS
fi

SERVER_PORT=$INPUT_SERVER_PORT
if ! [[ -z ${INPUT_SERVER_PORT} ]]; then
  SERVER_PORT=$INPUT_SERVER_PORT
fi

FOLDER=$INPUT_FOLDER
if ! [[ -z ${INPUT_FOLDER} ]]; then
  FOLDER=$INPUT_FOLDER
fi

set -eu

SSHPATH="$HOME/.ssh"
mkdir -p "$SSHPATH"
echo "$DEPLOY_KEY" > "$SSHPATH/key"
chmod 600 "$SSHPATH/key"
SERVER_DEPLOY_STRING="$USERNAME@$SERVER_IP:$SERVER_DESTINATION"
# sync it up"
sh -c "rsync $ARGS -e 'ssh -i $SSHPATH/key -o StrictHostKeyChecking=no -p $SERVER_PORT' $GITHUB_WORKSPACE/@sync/$FOLDER $SERVER_DEPLOY_STRING"
