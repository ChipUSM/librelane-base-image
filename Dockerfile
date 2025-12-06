FROM ubuntu:24.04
RUN apt-get update && apt-get install -y python3 python3-pip curl systemd git
ADD install-nix.sh /tmp/install-nix.sh
RUN /tmp/install-nix.sh

# Clone LibreLane repository
USER root
RUN git clone https://github.com/librelane/librelane.git /opt/librelane && \
    chown -R designer:designer /opt/librelane

# Install LibreLane from dev branch using Nix
RUN cd /opt/librelane && \
    git checkout dev && \
    nix profile install . --extra-experimental-features "nix-command flakes"

RUN pip install "cocotb~=2.0"  --break-system-packages
RUN useradd -ms /bin/bash designer \
    && usermod -aG sudo designer

ENTRYPOINT ["/bin/bash", "-l"]