# multistage build for http-echo-rs
# eg. build command
# docker build \
#        --build-arg GITHUB_REPOSITORY_OWNER="$(git config user.name)" \
#        --build-arg GITHUB_ACTOR="$(git config user.name)" \
#        --build-arg GITHUB_TOKEN=$(grep -oP "(?<=$(git config user.name):).*(?=@)" ~/.git-credentials) \
#        --build-arg GITHUB_REPOSITORY=http-echo-rs \
#        -t fjolsvin/http-echo-rs:$(git describe --tags) .

FROM rust:alpine as base

ARG GITHUB_REPOSITORY_OWNER
ENV GITHUB_REPOSITORY_OWNER $GITHUB_REPOSITORY_OWNER

ARG GITHUB_REPOSITORY
ENV GITHUB_REPOSITORY $GITHUB_REPOSITORY

ARG GITHUB_ACTOR
ENV GITHUB_ACTOR $GITHUB_ACTOR

ARG GITHUB_TOKEN
ENV GITHUB_TOKEN $GITHUB_TOKEN
ENV TERM=xterm
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk upgrade -U -a && \
    apk add build-base make git bash ncurses upx
RUN git clone "https://$GITHUB_ACTOR:$GITHUB_TOKEN@github.com/$GITHUB_REPOSITORY_OWNER/$GITHUB_REPOSITORY.git" "/workspace/$GITHUB_REPOSITORY"
WORKDIR "/workspace/$GITHUB_REPOSITORY"
RUN make release
RUN echo "nobody:x:65534:65534:Nobody:/:" > /etc_passwd
FROM scratch
ARG GITHUB_REPOSITORY
ENV GITHUB_REPOSITORY $GITHUB_REPOSITORY
COPY --from=base /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=base /etc_passwd /etc/passwd
COPY --from=base --chown=65534:0 "/workspace/$GITHUB_REPOSITORY/target/release/entrypoint" /entrypoint
USER nobody
ENTRYPOINT ["/entrypoint"]