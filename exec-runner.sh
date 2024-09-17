#!/bin/bash

if [ -z "${GITHUB_ACCESS_TOKEN}" ]; then
  echo "GITHUB_ACCESS_TOKEN must be set" 1>&2
  exit 1
fi

if [ -z "${GITHUB_API_DOMAIN}" ]; then
  echo "GITHUB_API_DOMAIN must be set" 1>&2
  exit 1
fi

if [ -z "${GITHUB_DOMAIN}" ]; then
  echo "GITHUB_DOMAIN must be set" 1>&2
  exit 1
fi

if [ -z "${GITHUB_REPOSITORY_NAME}" ]; then
  echo "GITHUB_REPOSITORY_NAME must be set" 1>&2
  exit 1
fi

if [ -z "${GITHUB_REPOSITORY_OWNER}" ]; then
  echo "GITHUB_REPOSITORY_OWNER must be set" 1>&2
  exit 1
fi

export GITHUB_RUNNER_REGISTRATION_TOKEN=$(curl \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GITHUB_ACCESS_TOKEN" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    https://$GITHUB_API_DOMAIN/repos/$GITHUB_REPOSITORY_OWNER/$GITHUB_REPOSITORY_NAME/actions/runners/registration-token \
    | jq .token | sed -e 's/"//g')

export RUNNER_ALLOW_RUNASROOT=1
runnerName=`hostname`

expect -c "
set timeout 10
log_user 0
spawn ./config.sh --url https://${GITHUB_DOMAIN}/${GITHUB_REPOSITORY_OWNER}/${GITHUB_REPOSITORY_NAME} --token ${GITHUB_RUNNER_REGISTRATION_TOKEN} --ephemeral
log_user 1
expect  -re \"Enter the name of the runner group to add this runner to:.*\"
send \"\n\"
expect  -re \"Enter the name of runner:.*\"
send \"${runnerName}\n\"
expect  -re \"Enter any additional labels.*\"
send \"\n\"
expect  -re \"Enter name of work folder:.*\"
send \"\n\"
expect \"#\"
exit 0
"

# ./config.sh \
#     --unattended \
#     --url https://${GITHUB_DOMAIN}/${GITHUB_REPOSITORY_OWNER}/${GITHUB_REPOSITORY_NAME} \
#     --pat ${GITHUB_RUNNER_REGISTRATION_TOKEN} \
#     --name ${runnerName} \
#     --runnergroup $RUNNER_GROUP \
#     --labels $RUNNER_LABELS \
#     --work $RUNNER_WORKDIR

./run.sh
