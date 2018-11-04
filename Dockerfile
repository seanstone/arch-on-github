FROM base/archlinux:latest

RUN pacman --noconfirm -Syu && \
    pacman --noconfirm -S \
      binutils \
      curl \
      fakeroot \
      gcc \
      make \
      openssl \
      patch \
      pkg-config \
      bison \
      flex \
      sudo && \
    pacman --noconfirm -Sc

RUN useradd --create-home builduser && \
    echo 'builduser ALL=(ALL) NOPASSWD: ALL' \
    | EDITOR='tee -a' visudo

USER builduser
WORKDIR /home/builduser
