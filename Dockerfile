FROM ubuntu:22.04
RUN apt-get update && apt-get install -y python3 python3-pip curl systemd git sudo

ARG USERNAME=designer
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --create-home --no-log-init --uid $USER_UID --gid $USER_GID $USERNAME \
    && echo "designer ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/designer

#RUN useradd --uid $USER_UID --gid $USER_GID $USERNAME \
#    && chown -R $USER_UID:$USER_GID /home/$USERNAME

#RUN useradd -ms /bin/bash designer 

USER root
RUN chown -R designer:designer /opt

USER designer
WORKDIR /home/designer
ENV USER=designer
SHELL ["/bin/bash", "-lc"]

# Install Nix in single-user mode for designer user
RUN curl -L https://nixos.org/nix/install | sh -s -- --no-daemon --yes

# Configure Nix with custom substituters and enable flakes
RUN mkdir -p ~/.config/nix && \
    echo 'extra-substituters = https://nix-cache.fossi-foundation.org' > ~/.config/nix/nix.conf && \
    echo 'extra-trusted-public-keys = nix-cache.fossi-foundation.org:3+K59iFwXqKsL7BNu6Guy0v+uTlwsxYQxjspXzqLYQs=' >> ~/.config/nix/nix.conf && \
    echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf

ENV PATH="/home/designer/.nix-profile/bin:/home/designer/.nix-profile/sbin:${PATH}"

# Clone LibreLane repository
RUN git clone https://github.com/librelane/librelane.git /opt/librelane && \
    cd /opt/librelane && git submodule update --init --recursive && \
    nix profile add .

ENTRYPOINT ["/bin/bash", "-l"]