 <p align="left">
<b><i>Kubernetes deployment of MySQL cluster </i></b>
</p>
<p align="left">
<a herf="https://img.shields.io/badge/CNCF-Kubernetes-informational?style=flat&logo=Kubernetes&color=777BB4"><img src="https://img.shields.io/badge/CNCF-Kubernetes-informational?style=flat&logo=Kubernetes&color=777BB4"></a>
<a href="https://img.shields.io/github/issues/sush-sketc/Kubernetes-study-doc"><img src="https://img.shields.io/github/issues/sush-sketc/Kubernetes-study-doc"></a>
<a href="https://img.shields.io/github/license/sush-sketc/Kubernetes-study-doc"><img src="https://img.shields.io/github/license/sush-sketc/Kubernetes-study-doc"></a>
<a herf="https://img.shields.io/badge/mysql-db-v1?style=plastic&logo=MySQL&labelColor=%23DEB887&color=%236495ED"><img src="https://img.shields.io/badge/mysql-db-v1?styl&logo=MySQL&labelColor=%23DEB887&color=%236495ED"></a>
</p>

---
### 集群信息

| NAME | STATUS | ROLES | AGE | VERSION | INTERNAL-IP | EXTERNAL-IP | OS-IMAGE | KERNEL-VERSION | CONTAINER-RUNTIME
| :-- | :-- | :-- | :-- | :-- | :-- | :-- | :-- | :-- | :-- | 
| sketc-ssh.master1 | Ready | control-plane | 2d2h | v1.25.16 | 10.50.1.130 | <none> | Rocky Linux 9.4 (Blue Onyx) | 5.14.0-427.40.1.el9_4.aarch64 | containerd://1.6.36
| sketc-ssh.master2 | Ready | control-plane | 2d2h | v1.25.16 | 10.50.1.134 | <none> | Rocky Linux 9.4 (Blue Onyx) | 5.14.0-427.40.1.el9_4.aarch64 | containerd://1.6.36
| sketc-ssh.node1 | Ready | <none> | 2d1h | v1.25.16 | 10.50.1.131 | <none> | Rocky Linux 9.4 (Blue Onyx) | 5.14.0-427.40.1.el9_4.aarch64 | containerd://1.6.36
| sketc-ssh.node2 | Ready | <none> | 2d | v1.25.16 | 10.50.1.132 | <none> | Rocky Linux 9.4 (Blue Onyx) | 5.14.0-427.40.1.el9_4.aarch64 | containerd://1.6.36

---
### 镜像版本
| NAME | Version |
| :-- | :-- |
| [MySQL](https://dev.mysql.com/doc/) | 8.0.18 |
| [xtrabackup](https://docs.percona.com/percona-xtrabackup/8.0/release-notes.html) | 8.0.9 |

> 注意: MySQL和xtrabacbup版本必须一致 <br>

### 部署NFS-SERVER
为了测试使用`sketc-ssh.master1` 主机作为NFS-SERVER
```sh
# 所有节点安装nfs
yum -y install nfs-utils

# 创建nfs挂载目录
# 此处为了测试，如果重要环境可能会需要额外的挂载磁盘作为nfs存储
mkdir -p /nfs-storage/mysql-storage/

#增加nfs配置
sudo tee  /etc/exports <<"EOF"
/nfs-storage/mysql-storage *(rw,sync,no_root_squash)
EOF

#重启nfs服务
systemctl restart rpcbind.service
systemctl restart nfs-utils.service 
systemctl restart nfs-server.service 

# 增加NFS-SERVER开机自启动
systemctl enable nfs-server.service 

# 验证NFS-SERVER是否能正常访问
showmount -e 10.50.1.130 
# 输出是下面这样就成功
# Export list for 10.50.1.130:
# /nfs-storage/mysql-storage *
```
### 创建NAMESPACE
```sh
kubectl create namespace sks-clusterset-db-ha1
```
### 创建 StorageClass动态存储(动态生成PersistentVolume)
+ 执行`kubectl apply -f  nfs-clinet-rbac.yaml` 创建RBAC权限
+ 执行`nfs-client-provisioner.yml` 创建nfs-client-provisioner
+ 执行`ConfigMap.yaml` 创建配置文件
+ 执行`secret.yaml` 创建MySQL密钥 (Opaque类型，data里面的值必须填base64加密后的内容)
+ 执行`service.yaml` 创建无头服务(Headless Service)来控制网络域名
+ 执行

### （可选）制作XtraBackup镜像
由于当前外部容器镜像仓库中没有找到可用的ARM版本XtraBackup镜像，因此需制作XtraBackup（ARM）镜像，用于搭建StatefulSet MySQL集群。
> 位置：./percona-xtrabackup <br>
+ 获取编译XtraBackup依赖
  +   [percona-xtrabackup](https://github.com/percona/percona-xtrabackup/releases/tag/percona-xtrabackup-8.0.29-22)
  +   [boost](https://www.boost.org/users/history/version_1_77_0.html)
  +   [libkmip](https://github.com/Percona-Lab/libkmip/tree/0ecda33598838b67bb4bb7a0005c92eea8b7405a)<br>

参考XtraBackup官网编译ARM版本XtraBackup软件包流程，编写制作XtraBackup镜像的Dockerfile
+ 参考 Dockerfile  -->  ./percona-xtrabackup/Dockerfile
+ 参考 buildx command  -- >  ./percona-xtrabackup/buildx-arm64.sh <br>





