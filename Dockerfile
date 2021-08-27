## NOTE: to retain configuration; mount a Docker volume, or use a bind-mount, on /var/lib/zerotier-one

FROM debian:buster-slim as builder

## Supports x86_64, x86, arm, and arm64

ARG ZT_VERSION=1.6.5
RUN apt-get update && apt-get install -y curl gnupg && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1657198823E52A61 && \
    echo "deb http://download.zerotier.com/debian/buster buster main" > /etc/apt/sources.list.d/zerotier.list && \
    apt-get update && apt-get install -y zerotier-one=${ZT_VERSION}
COPY init.sh /var/lib/zerotier-one/init.sh

FROM debian:buster-slim
LABEL version="$(ZT_VERSION)"
LABEL description="Containerized ZeroTier One for use on CoreOS or other Docker-only Linux hosts."

# ZeroTier relies on UDP port 9993
EXPOSE 9993/udp

RUN mkdir -p /var/lib/zerotier-one
COPY --from=builder /usr/sbin/zerotier-cli /usr/sbin/zerotier-cli
COPY --from=builder /usr/sbin/zerotier-idtool /usr/sbin/zerotier-idtool
COPY --from=builder /usr/sbin/zerotier-one /usr/sbin/zerotier-one
COPY --from=builder /var/lib/zerotier-one/init.sh /init.sh

RUN chmod 0755 /init.sh
ENTRYPOINT ["/init.sh"]
CMD ["zerotier-one"]
