FROM seanstone/arch-on-github:latest

RUN sudo pacman --noconfirm -Syu

RUN sudo pacman --noconfirm -S perl-rename