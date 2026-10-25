
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    build-essential \
    ca-certificates \
    curl \
    git \
    pkg-config \
    libreadline-dev \
    unzip \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://mise.run | sh \
    && ln -sf /root/.local/bin/mise /usr/local/bin/mise

WORKDIR /workspace
