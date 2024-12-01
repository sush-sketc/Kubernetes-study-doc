# step1: build mysql_connector_odbc
FROM ubuntu:20.04 AS builder

ENV INSTALL_PATH="/usr/local/mysql/"
ENV DATADIR_PATH="/mysql"
# ENV SECURE_FILE_PATH=""
# ENV TCP_PORT="3306"
ENV UNIX_ADDR="/var/run/mysqld"
ENV COMMENT_INFO="MySQL Server (GPL) Customised Version by ShengHong SU"
#跳过交互式配置
ENV DEBIAN_FRONTEND=noninteractive
# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
# install dependencies
RUN set -ux; \
    groupadd mysql && useradd -g mysql mysql && \
    apt-get update  && apt install -y build-essential cmake bison libncurses5-dev libssl-dev pkg-config systemd libtirpc-dev wget tzdata && \
    ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && dpkg-reconfigure -f noninteractive tzdata && \
    wget -c  https://cdn.mysql.com/archives/mysql-8.0/mysql-boost-8.0.18.tar.gz -O - | tar -zxvf -  -C / 
    
# download source code
# WORKDIR /build
ENV MYSQL_MAJOR=8.0
ENV MYSQL_VERSION=8.0.18ubuntu_arm64
#编译
RUN cd /mysql-8.0.18 && cmake -DCMAKE_INSTALL_PREFIX=${INSTALL_PATH} \
        -DINSTALL_LAYOUT=STANDALONE \
        -DMYSQL_DATADIR=${DATADIR_PATH} \
        -DDEFAULT_CHARSET=utf8mb4 \
        -DDEFAULT_COLLATION=utf8mb4_general_ci \
        -DINSTALL_SECURE_FILE_PRIVDIR=${DATADIR_PATH}/mysql-files \
        -DENABLED_LOCAL_INFILE=OFF \
        -DBUILD_CONFIG=${MYSQL_VERSION} \
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
        -DFORCE_INSOURCE_BUILD=1 \
        -DWITH_BOOST=boost && \
        make -j 5 && make install && \
        mkdir -p /var/lib/mysql /var/run/mysqld && \
        chown -R mysql:mysql ${INSTALL_PATH} /var/lib/mysql /var/run/mysqld 

COPY docker-entrypoint.sh /usr/local/bin/
COPY config/ /etc/mysql/
RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh # backwards compat
ENTRYPOINT ["docker-entrypoint.sh"]


EXPOSE 3306 33060
CMD ["mysqld"]
# RUN ${INSTALL_PATH}/bin/mysqld --defaults-file=${mysqlcnf} --initialize --user=mysql
## DFORCE_INSOURCE_BUILD=1 这个在mysql5.7版本不会碰到，版本8以后的一个改进，目的是方便系统管理员在一份源吗下灵活的安装多份配置各异的mysql实例
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