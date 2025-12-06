FROM ubuntu:24.04
RUN apt-get update && apt-get install -y python3 python3-pip curl systemd git
ADD install-nix.sh /tmp/install-nix.sh
RUN /tmp/install-nix.sh
RUN pip install "cocotb~=2.0"  --break-system-packages

# Create /run/user/1000/ directory for X11 and systemd runtime files
RUN mkdir -p /run/user/1000 && \
    chmod 700 /run/user/1000 && \
    chown designer:designer /run/user/1000

USER designer

ENTRYPOINT ["/bin/bash", "-l"]