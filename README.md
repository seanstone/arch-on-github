# Arch on GitHub

[![Build Status](https://travis-ci.com/AlexandreCarlton/arch-on-github.svg?branch=master)](https://travis-ci.com/AlexandreCarlton/arch-on-github)

An experiment to create an Arch custom repository, building packages from the
AUR and hosting them via [GitHub Releases](https://help.github.com/articles/about-releases/)

## Usage

To use this "repository", include the following in your `/etc/pacman.conf`:

```conf
[github]
SigLevel = Optional TrustAll
Server = https://github.com/AlexandreCarlton/arch-on-github/releases/latest
```
