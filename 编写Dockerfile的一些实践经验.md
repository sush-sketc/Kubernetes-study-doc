### 基于alpine的glibc基础镜像

实际上我们基于https://github.com/sgerrand/alpine-pkg-glibc这个项目，从官方的alpine镜像构建出了alpine-glibc作为我们的基础镜像。alpine-glibc基础镜像参考了https://github.com/Docker-Hub-frolvlad/docker-alpine-glibc/blob/master/Dockerfile这个Dockerfile。我们在这个Dockerfile的基础上加了一层对时区的定制，将时区修改为中国时区。

https://blog.frognew.com/2021/07/relearning-container-25.html