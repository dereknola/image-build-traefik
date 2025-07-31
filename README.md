# rancher/hardened-traefik


This repository created a hardened, FIPS 140-2 compatible, binary version of [Traefik](https://github.com/traefik/traefik) and deploys it in a scratch image.

## Build

```sh
TAG=v3.5.0 make image-build
```