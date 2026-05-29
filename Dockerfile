FROM debian:bookworm-slim

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    jq \
    bash \
    coreutils \
    file \
    tar \
    gzip \
    unzip \
    tini \
  && rm -rf /var/lib/apt/lists/*

COPY runner /usr/local/bin/runner
COPY lib/ /usr/local/lib/runner/

RUN chmod +x /usr/local/bin/runner \
  && find /usr/local/lib/runner -type f -name '*.sh' -exec chmod +x {} + \
  && mkdir -p \
    /opt/runner/bin \
    /var/lib/app \
    /var/lib/runner/work \
    /var/lib/runner/download \
    /run/runner

ENTRYPOINT ["/usr/bin/tini", "--", "runner"]
CMD ["run"]
