FROM archlinux/base:latest

ARG USERNAME
ARG REPO

RUN echo "[$USERNAME]" >> /etc/pacman.conf
RUN echo "SigLevel = Optional TrustAll" >> /etc/pacman.conf
RUN echo "Server = https://github.com/$USERNAME/$REPO/releases/download/latest" >> /etc/pacman.conf

RUN pacman --noconfirm -Syu

RUN pacman --noconfirm -S base-devel jq perl-rename

RUN useradd --create-home builduser && \
    echo 'builduser ALL=(ALL) NOPASSWD: ALL' \
    | EDITOR='tee -a' visudo

USER builduser
WORKDIR /home/builduser
