FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
    build-essential git make curl devscripts dh-make linux-libc-dev \
    apt-rdepends ca-certificates libsystemd-dev dpkg-dev libseccomp-dev libgpgme11\
    libgpgme-dev libc6 libdevmapper1.02.1 libgpgme11t64 libseccomp2 libsqlite3-0 libsubid4\
    jq gcc pkgconf libtool libprotobuf-c-dev libcap-dev libyajl-dev \
    go-md2man autoconf python3 automake libtool-bin libapparmor-dev libbtrfs-dev \
    sudo pkg-config libglib2.0-dev libc6-dev


RUN curl -sSL https://go.dev/dl/go1.23.3.linux-amd64.tar.gz | tar -C /usr/local -xz && \
    ln -s /usr/local/go/bin/go /usr/bin/go

WORKDIR /src

COPY ./scripts /src/scripts

RUN chmod +x -R /src/scripts