FROM alpine:3.22

RUN apk add --no-cache \
    bash \
    ca-certificates \
    curl \
    git \
    build-base \
    pkgconf \
    readline-dev \
    && curl -fsSL https://mise.run | sh \
    && ln -s /root/.local/bin/mise /usr/local/bin/mise

WORKDIR /workspace

CMD ["/bin/bash"]
