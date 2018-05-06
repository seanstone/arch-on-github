# Arch on GitHub

An experiment to create an Arch custom repository, building packages from the
AUR and hosting them via [GitHub Releases](https://help.github.com/articles/about-releases/)

## Usage

To use this "repository", include the following in your `/etc/pacman.conf`:

```conf
[github]
SigLevel = Optional TrustAll
Server = https://github.com/AlexandreCarlton/arch-on-github/releases/latest
```
