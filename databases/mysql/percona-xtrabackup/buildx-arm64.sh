#!/bin/bash

# 8.0.29-22
XTRABACKUP_TAR="percona-xtrabackup-percona-xtrabackup-8.0.29-22.tar.gz"
XTRABACKUP_BASE_DIR="percona-xtrabackup-percona-xtrabackup-8.0.29-22"
BOOST_TAR="boost_1_77_0.tar.gz"
BOOST_BASE_DIR="boost_1_77_0"
LIBKMIP_ZIP="libkmip-0ecda33598838b67bb4bb7a0005c92eea8b7405a.zip"
LIBKMIP_BASE_DIR="libkmip-0ecda33598838b67bb4bb7a0005c92eea8b7405a"

docker buildx build --platform=linux/arm64 --build-arg XTRABACKUP_TAR=${XTRABACKUP_TAR} --build-arg XTRABACKUP_BASE_DIR=${XTRABACKUP_BASE_DIR} --build-arg BOOST_TAR=${BOOST_TAR} --build-arg BOOST_BASE_DIR=${BOOST_BASE_DIR} --build-arg LIBKMIP_ZIP=${LIBKMIP_ZIP} --build-arg LIBKMIP_BASE_DIR=${LIBKMIP_BASE_DIR} -o type=docker -t mysql/xtrabackup:8.0.29-22-arm64 .