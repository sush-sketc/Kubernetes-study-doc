<p align="left">
<b><i><font size=5> StorageClass + NFS，实现 NFS 的动态 PV 创建</font></i></b>
</p>
<p align="left">
<a herf="https://img.shields.io/badge/CNCF-Kubernetes-informational?style=flat&logo=Kubernetes&color=777BB4"><img src="https://img.shields.io/badge/CNCF-Kubernetes-informational?style=flat&logo=Kubernetes&color=777BB4">
<a herf="https://img.shields.io/badge/StorageClass-informational?style=flat&logo=nfs&color=777BB4"><img src="https://img.shields.io/badge/StorageClass-informational?style=flat&logo=StorageClass&color=777BB4">
<a herf="https://img.shields.io/badge/apiversion-informational?style=flat&logo=apiversion&color=FCC624"><img src="https://img.shields.io/badge/apiversion-informational?style=flat&logo=apiversion&color=FCC624"></a>
<a href="https://img.shields.io/github/issues/sush-sketc/Kubernetes-study-doc"><img src="https://img.shields.io/github/issues/sush-sketc/Kubernetes-study-doc"></a>
<!--<a href="https://img.shields.io/github/v/release/radondb/radondb-mysql-kubernetes?include_prereleases"><img src="https://img.shields.io/github/v/release/sush-sketc/Kubernetes-study-doc?include_prereleases"></a> -->
<a href="https://img.shields.io/github/license/sush-sketc/Kubernetes-study-doc"><img src="https://img.shields.io/github/license/sush-sketc/Kubernetes-study-doc"></a>
<a href="https://goreportcard.com/report/github.com/radondb/radondb-mysql-kubernetes"><img src="https://goreportcard.com/badge/github.com/radondb/radondb-mysql-kubernetes" alt="A+"></a>
<a href="https://img.shields.io/github/stars/sush-sketc/Kubernetes-study-doc"><img src="https://img.shields.io/github/stars/sush-sketc/Kubernetes-study-doc"></a>
</a>
</p>

----
### 1，`StorageClass` 存储类
`StorageClass` 存储类用于描述集群中可以提供的存储类型，不同的存储类可能对应这不同的意义: <br>

+ 服务等级(`quality-of-service level`)
+ 备份策略
+ 集群管理员自定义的策略 <br>
> 说明： Kubernetes 自身对存储类所代表的含义并无感知，由集群管理员自行约定。
### 2,`StorageClass` 资源
每个 StorageClass 都包含 provisioner、parameters 和 reclaimPolicy 字段， 这些字段会在 StorageClass 需要动态分配 PersistentVolume 时会使用到。
StorageClass 对象的命名很重要，用户使用这个命名来请求生成一个特定的类。 当创建 StorageClass 对象时，管理员设置 StorageClass 对象的命名和其他参数，一旦创建了对象就不能再对其更新 <br>

### 3,实现NFS的动态PersistentVolume创建
Kubernetes 本身支持的动态 PersistentVolume 创建不包括 NFS，所以需要使用外部存储卷插件分配PV。
卷插件称为 Provisioner（存储分配器），NFS 使用的是 nfs-client，这个外部卷插件会使用已经配置好的 NFS 服务器自动创建 PersistentVolume。 Provisioner：用于指定 Volume 插件的类型，包括内置插件（如 kubernetes.io/aws-ebs）和外部插件（如 external-storage 提供的 ceph.com/cephfs）。<br>
### 4, 在master节点安装nfs,并配置nfs服务
```bash
# 在部署节点上安装nfs
sudo yum -y install nfs-utils

# 创建nfs挂载目录
sudo mkdir -p /nfs-storage/mysql-storage #可以指定自己的路径

#增加nfs配置
echo    '/nfs-storage/mysql-storage *(rw,sync,no_root_squash)' >> /etc/exports
#or
sudo tee /etc/exports <<"EOF"
/nfs-storage/mysql-storage *(rw,sync,no_root_squash)
EOF

#重启nfs服务
sudo systemctl restart rpcbind.service
sudo systemctl restart nfs-utils.service 
sudo systemctl restart nfs-server.service 

# 增加NFS-SERVER开机自启动
sudo systemctl enable nfs-server.service 

# 验证NFS-SERVER是否能正常访问
showmount -e 10.50.1.130   #10.50.1.130本机ip地址
# 输出是下面这样就成功
# Export list for 10.10.10.90:
# /net/mysql *
```
### 5，创建StorageClass动态存储(动态生成PersistentVolume)
创建 Service Account，用来管理 NFS Provisioner 在 k8s 集群中运行的权限，设置 nfs-client 对 PV，PVC，StorageClass 等的规则<br>
```shell
# nfs-client-rbac.yaml
#创建 Service Account 账户，用来管理 NFS Provisioner 在 k8s 集群中运行的权限
kubectl apply -f nfs-client-rbac.yaml
```
如果执行命令成功则查看
```sh
kubectl --kubeconfig kubeadm-config sa -A |grep nfs
#输出如下
#default           nfs-client-provisioner               0         42s
kubectl --kubeconfig kubeadm-config get clusterrole -A|grep nfs
#输出如下
#nfs-client-provisioner-clusterrole                                     2024-11-23T09:33:05Z
kubectl --kubeconfig kubeadm-config get clusterrolebindings.rbac.authorization.k8s.io -A|grep nfs  
#输出如下
#nfs-client-provisioner-clusterrolebinding              ClusterRole/nfs-client-provisioner-clusterrole
```
