FROM base/archlinux:latest

RUN pacman --noconfirm -Syu && \
    pacman --noconfirm -S \
      base-devel \
      curl \
      openssl && \
    pacman --noconfirm -Sc

RUN useradd --create-home builduser && \
    echo 'builduser ALL=(ALL) NOPASSWD: ALL' \
    | EDITOR='tee -a' visudo

USER builduser
WORKDIR /home/builduser
