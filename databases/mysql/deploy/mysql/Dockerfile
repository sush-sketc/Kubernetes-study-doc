# step1: build mysql_connector_odbc
FROM alpine:3.17 AS builder

ENV INSTALL_PATH="/usr/local/mysql/"
ENV DATADIR_PATH="/mysql"
# ENV SECURE_FILE_PATH=""
# ENV TCP_PORT="3306"
ENV UNIX_ADDR="/var/run/mysqld"
ENV COMMENT_INFO="MySQL Server (GPL) Customised Version by ShengHong SU"
# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
# install dependencies
RUN addgroup -S mysql && adduser -S mysql -G mysql && apk update && apk add --no-cache --virtual .build-deps cmake make g++ openssl-dev ncurses-dev unixodbc-dev wget zlib-dev \
    tzdata \
    automake \
    autoconf \
    libtool \
    linux-headers \
    libev-dev \
    gnutls-dev \
    libcurl && \
    wget -q https://cdn.mysql.com/archives/mysql-8.0/mysql-boost-8.0.18.tar.gz | ter -xzf -  -C / 
    
# download source code
# WORKDIR /build

#编译
RUN cd cmake -DCMAKE_INSTALL_PREFIX=${INSTALL_PATH} \
-DINSTALL_LAYOUT=STANDALONE \
-DMYSQL_DATADIR=${DATADIR_PATH} \
-DDEFAULT_CHARSET=utf8mb4 \
-DDEFAULT_COLLATION=utf8mb4_general_ci \
-DINSTALL_SECURE_FILE_PRIVDIR=${DATADIR_PATH}/mysql-files \
-DENABLED_LOCAL_INFILE=OFF \
-DSYSCONFDIR=${INSTALL_PATH} \
-DMYSQL_UNIX_ADDR=${UNIX_ADDR} \
-DWITH_SYSTEMD=ON \
-DSYSTEMD_SERVICE_NAME=mysqld \
-DCOMPILATION_COMMENT='${COMMENT_INFO}' \
-DWITH_ARCHIVE_STORAGE_ENGINE=1 \
-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
-DWITH_PERFSCHEMA_STORAGE_ENGINE=1 \
-DWITH_EXAMPLE_STORAGE_ENGINE=1 \
-DWITH_FEDERATED_STORAGE_ENGINE=1 \
-DWITH_PARTITION_STORAGE_ENGINE=1 \
-DWITH_BOOST=boost && mkdir -p ${DATADIR_PATH}/mysql-files
# compile libmysqlclient.so
# WORKDIR /build/build_client
# RUN cmake -DWITHOUT_SERVER=ON -DWITH_BOOST=/build/mysql-8.0.15/boost /build/mysql-8.0.15
# RUN make && make install
# # compile libmyodbc8w.so & libmyodbc8a.so
# RUN mysqld --defaults-file=${mysqlcnf} --initialize --user=mysql

# # step2: install mysql_connector_odbc
# FROM node:18.9.0-alpine3.16
# COPY --from=builder /build/build_connector/mysql-connector-odbc-8.0.15 /opt/mysql-connector-odbc-8.0.15
# COPY config/ /etc/mysql/
# COPY docker-entrypoint.sh /usr/local/bin/
# ENTRYPOINT ["tail", "-f", "/dev/null"]