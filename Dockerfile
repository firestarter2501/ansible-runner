FROM ubuntu:latest

ARG PERSONAL_ACCESS_TOKEN
ARG HOST=https://github.com
ARG ORGANIZATION
ARG REPOSITORY

ENV BINARY_URL=https://github.com/actions/runner/releases/download/v2.319.1/actions-runner-linux-x64-2.319.1.tar.gz

ENV RUNNER_NAME=myrunner
ENV RUNNER_GROUP=Default
ENV RUNNER_LABELS="self-hosted,Linux,X64"
ENV RUNNER_WORKDIR=_work

RUN apt update && \
    apt install -y dotnet-sdk-7.0 curl sudo openssh-client && \
    apt clean && rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN useradd runner && \
    echo "runner:runner" | chpasswd && \
    chsh -s /usr/bin/bash runner && \
    usermod -aG sudo runner && \
    mkdir /actions-runner && \

    chown runner:runner /actions-runner

USER runner
WORKDIR /actions-runner

RUN curl -fsSL -o actions-runner.tar.gz -L $BINARY_URL && \
    tar xf actions-runner.tar.gz && \
    rm actions-runner.tar.gz && \
    echo $PERSONAL_ACCESS_TOKEN && \
    ./config.sh \
        --unattended \
        --url $HOST/$ORGANIZATION/$REPOSITORY \
        --pat $PERSONAL_ACCESS_TOKEN \
        --name $RUNNER_NAME \
        --runnergroup $RUNNER_GROUP \
        --labels $RUNNER_LABELS \
        --work $RUNNER_WORKDIR

CMD ["./run.sh"]


