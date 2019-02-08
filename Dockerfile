FROM archlinux/base:latest

RUN pacman --noconfirm -Syu

RUN pacman --noconfirm -S base-devel wget

RUN useradd --create-home builduser && \
    echo 'builduser ALL=(ALL) NOPASSWD: ALL' \
    | EDITOR='tee -a' visudo

USER builduser
WORKDIR /home/builduser
