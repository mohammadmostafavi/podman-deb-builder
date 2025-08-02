FROM ubuntu:24.04

RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y \
    build-essential git make golang curl devscripts dh-make \
    apt-rdepends ca-certificates

WORKDIR /src

ENTRYPOINT ["/bin/bash"]
