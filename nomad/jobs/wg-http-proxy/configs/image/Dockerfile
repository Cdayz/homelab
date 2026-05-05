FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    wireguard-tools \
    iptables \
    squid \
    ca-certificates \
    iproute2 \
    procps \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
