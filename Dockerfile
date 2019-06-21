FROM archlinux/base:latest

RUN pacman --noconfirm -Syu

RUN pacman --noconfirm --needed -S base-devel jq perl-rename

RUN useradd --create-home builduser && \
    echo 'builduser ALL=(ALL) NOPASSWD: ALL' \
    | EDITOR='tee -a' visudo

USER builduser
WORKDIR /home/builduser
