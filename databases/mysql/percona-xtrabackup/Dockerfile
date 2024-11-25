FROM ubuntu:20.04 AS builder

ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG XTRABACKUP_TAR
ARG XTRABACKUP_BASE_DIR
ARG BOOST_TAR
ARG BOOST_BASE_DIR
ARG LIBKMIP_ZIP
ARG LIBKMIP_BASE_DIR

ENV DEBIAN_FRONTEND=noninteractive

RUN apt clean && apt autoclean && apt update &&  \
    apt install -y \
    dirmngr \
    cmake \
    lsb-release wget \
    build-essential \
    flex \
    bison \
    automake \
    autoconf \
    libtool \
    cmake \
    libaio-dev \
    mysql-client \
    libncurses-dev \
    zlib1g-dev \
    libev-dev \
    libcurl4-gnutls-dev \
    vim-common \
    devscripts \
    libnuma-dev \
    openssl \
    libssl-dev \
    libgcrypt20-dev \
    libprocps-dev \
    libudev-dev \
    git && echo "依赖安装完成！"

ADD ${XTRABACKUP_TAR} /
ADD ${BOOST_TAR} /
ADD ${LIBKMIP_ZIP} /${XTRABACKUP_BASE_DIR}/extra/libkmip
RUN cd /${XTRABACKUP_BASE_DIR}/ && mkdir build && cd extra/libkmip && unzip ${LIBKMIP_ZIP} && cp -r ${LIBKMIP_BASE_DIR}/* .
RUN cd /${XTRABACKUP_BASE_DIR}/build && cmake .. -DDOWNLOAD_BOOST=OFF -DWITH_BOOST=/${BOOST_BASE_DIR} -DWITH_NUMA=1 -DCMAKE_INSTALL_PREFIX=/usr/local/xtrabackup && make -j4 && make install

FROM ubuntu:20.04

COPY --from=builder /usr/local/xtrabackup /usr/local/xtrabackup
ENV PATH=/usr/local/xtrabackup/bin:$PATH

RUN apt-get -y update &&\
    apt-get -y install libev-dev libcurl4-gnutls-dev libnuma-dev libaio-dev &&\
    apt-get -y install ncat &&\
    apt-get -y install mysql-client &&\
    apt-get clean && apt-get autoclean

EXPOSE 3307