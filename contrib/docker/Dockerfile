FROM alpine AS base
ARG GITHUB_REPOSITORY_OWNER
ENV GITHUB_REPOSITORY_OWNER $GITHUB_REPOSITORY_OWNER

ARG GITHUB_REPOSITORY
ENV GITHUB_REPOSITORY $GITHUB_REPOSITORY

ARG GITHUB_ACTOR
ENV GITHUB_ACTOR $GITHUB_ACTOR

ARG GITHUB_TOKEN
ENV GITHUB_TOKEN $GITHUB_TOKEN
ENV TERM=xterm
ENV RUSTUP_HOME=/usr/local/rustup 
ENV CARGO_HOME=/usr/local/cargo 
ENV PATH=/usr/local/cargo/bin:$PATH
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk upgrade -U -a && \
    apk add ca-certificates gcc build-base make git bash ncurses curl libressl-dev musl-dev libffi-dev upx
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- \
    -y \
    --no-modify-path \
    --default-host x86_64-unknown-linux-musl \
    --default-toolchain nightly \
    --profile minimal && \
    rustup --version && \
    cargo --version && \
    rustc --version

RUN git clone "https://$GITHUB_ACTOR:$GITHUB_TOKEN@github.com/da-moon/http-echo-rs.git" "/workspace/http-echo-rs"
WORKDIR /workspace/http-echo-rs
