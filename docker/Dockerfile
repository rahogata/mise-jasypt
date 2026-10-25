FROM alpine:3.22

RUN apk add --no-cache \
        build-base \
        make \
        pkgconf \
        readline-dev \
        ca-certificates \
        curl \
        openjdk17-jre-headless \
    && curl -fsSL https://mise.run | sh \
    && ln -s /root/.local/bin/mise /usr/local/bin/mise

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /workspace

CMD ["/bin/sh"]
