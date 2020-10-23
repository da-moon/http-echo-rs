FROM fjolsvin/gitpod-rust

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" | sudo tee /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" | sudo tee -a /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" | sudo tee -a /etc/apk/repositories && \
    sudo apk upgrade --no-cache
