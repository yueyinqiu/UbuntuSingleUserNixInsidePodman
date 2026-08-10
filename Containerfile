FROM ubuntu:26.04

ARG USER_NAME=ubuntu
ARG USER_PASSWORD=123456

RUN apt-get update
RUN apt-get install -y systemd
RUN apt-get install -y systemd-sysv
RUN apt-get install -y openssh-server
RUN apt-get install -y sudo
RUN apt-get install -y curl
RUN apt-get install -y xz-utils
RUN apt-get install -y git

RUN userdel -r ubuntu
RUN useradd -m -s /bin/bash "${USER_NAME}"
RUN echo "${USER_NAME}:${USER_PASSWORD}" | chpasswd
RUN usermod -aG sudo "${USER_NAME}"

RUN mkdir -p /nix && chown -R "${USER_NAME}" /nix
RUN su - "${USER_NAME}" -c "curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh -s -- --no-daemon"

STOPSIGNAL SIGRTMIN+3
CMD ["/sbin/init"]
