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
---
### (可选) 制作XtraBackup镜像
由于当前外部容器镜像仓库中没有找到可用的ARM版本XtraBackup镜像，因此需制作XtraBackup（ARM）镜像，用于搭建StatefulSet MySQL集群。
> 位置：./percona-xtrabackup <br>
+ 获取编译XtraBackup依赖
  +   [percona-xtrabackup](https://github.com/percona/percona-xtrabackup/releases/tag/percona-xtrabackup-8.0.29-22)
  +   [boost](https://www.boost.org/users/history/version_1_77_0.html)
  +   [libkmip](https://github.com/Percona-Lab/libkmip/tree/0ecda33598838b67bb4bb7a0005c92eea8b7405a)<br>

参考XtraBackup官网编译ARM版本XtraBackup软件包流程，编写制作XtraBackup镜像的Dockerfile
+ 参考 Dockerfile  -->  ./percona-xtrabackup/Dockerfile
+ 参考 buildx command  -- >  ./percona-xtrabackup/buildx-arm64.sh <br>
---

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
---
### 创建namespace
```sh
kubectl create namespace nfs-provisioner
```
---
### 创建 StorageClass动态存储(动态生成PersistentVolume)
创建 Service Account，用来管理 NFS Provisioner 在 k8s 集群中运行的权限，设置 nfs-client 对 PV，PVC，StorageClass 等的规则<br>
+ 创建RBAC权限 </br>
  ```sh 
  kubectl apply -f  nfs-clinet-rbac.yaml
  ``` 

  ```yaml
  #创建 Service Account 账户，用来管理 NFS Provisioner 在 k8s 集群中运行的权限
  apiVersion: v1
  kind: ServiceAccount
  metadata:
    name: nfs-client-provisioner
  ---
  #创建集群角色
  apiVersion: rbac.authorization.k8s.io/v1
  kind: ClusterRole
  metadata:
    name: nfs-client-provisioner-clusterrole
  rules:
  # 角色中可以访问的权限
    - apiGroups: [""]
      resources: ["persistentvolumes"]
      verbs: ["get", "list", "watch", "create", "delete"]
    - apiGroups: [""]
      resources: ["persistentvolumeclaims"]
      verbs: ["get", "list", "watch", "update"]
    - apiGroups: ["storage.k8s.io"]
      resources: ["storageclasses"]
      verbs: ["get", "list", "watch"]
    - apiGroups: [""]
      resources: ["events"]
      verbs: ["list", "watch", "create", "update", "patch"]
    - apiGroups: [""]
      resources: ["endpoints"]
      verbs: ["create", "delete", "get", "list", "watch", "patch", "update"]

  ---
  #集群角色绑定
  apiVersion: rbac.authorization.k8s.io/v1
  kind: ClusterRoleBinding
  metadata:
    name: nfs-client-provisioner-clusterrolebinding
  subjects:
    # 绑定角色 ServiceAccount
    - kind: ServiceAccount
      name: nfs-client-provisioner
      namespace: nfs-provisioner
  roleRef:
    kind: ClusterRole
    name: nfs-client-provisioner-clusterrole
    apiGroup: rbac.authorization.k8s.io
  ---
  kind: Role
  apiVersion: rbac.authorization.k8s.io/v1
  metadata:
    name: leader-locking-nfs-provisioner
  rules:
    - apiGroups: [""]
      resources: ["endpoints"]
      verbs: ["get", "list", "watch", "create", "update", "patch"]
  ---
  kind: RoleBinding
  apiVersion: rbac.authorization.k8s.io/v1
  metadata:
    name: leader-locking-nfs-provisioner
  subjects:
    - kind: ServiceAccount
      name: nfs-client-provisioner
      # replace with namespace where provisioner is deployed
      namespace: nfs-provisioner
  roleRef:
    kind: Role
    name: leader-locking-nfs-provisioner
    apiGroup: rbac.authorization.k8s.io
    ```
    
  > 创建后执行 
  >> 查看所创建 sa</br>
  >> `kubectl  get sa -A |grep nfs`</br>
  >> 查看 clusterrole</br>
  >> `kubectl get clusterrole -A|grep nfs`</br>
  >> 查看 clusterrolebindings</br>
  >> `kubectl get clusterrolebindings.rbac.authorization.k8s.io -A|grep nfs ` </br>                 

---


+ 创建nfs-client-provisioner
  ```sh
  nfs-client-provisioner.yaml
  ```

  ```yaml
  kind: Deployment
  apiVersion: apps/v1
  metadata:
    name: nfs-client-provisioner
  spec:
    replicas: 1
    selector:
      matchLabels:
        app: nfs-client-provisioner
    strategy:
      type: Recreate
    template:
      metadata:
        labels:
          app: nfs-client-provisioner
      spec:
        serviceAccountName: nfs-client-provisioner          #指定Service Account账户
        containers:
          - name: nfs-client-provisioner
            image: registry.k8s.io/sig-storage/nfs-subdir-external-provisioner:v4.0.2
            imagePullPolicy: IfNotPresent
            volumeMounts:
              - name: nfs-client-root
                mountPath: /persistentvolumes
            env:
              - name: TZ
                value: Asia/Shanghai    #容器时区
              - name: PROVISIONER_NAME
                value: nfs-storage       #配置provisioner的Name，确保该名称与StorageClass资源中的provisioner名称保持一致
              - name: NFS_SERVER
                value: 10.50.1.130          #配置绑定的nfs服务器
              - name: NFS_PATH
                value: /nfs-storage/mysql-storage          #配置绑定的nfs服务器目录，挂载路径
        volumes:              #申明nfs数据卷
          - name: nfs-client-root
            nfs:
              server: 10.50.1.130  #配置绑定的nfs服务器
              path: /nfs-storage/mysql-storage
  ---
  apiVersion: storage.k8s.io/v1
  kind: StorageClass
  metadata:
    name: nfs-client-storageclass
  provisioner: nfs-storage     #这里的名称要和provisioner配置文件中的环境变量PROVISIONER_NAME保持一致
  parameters:
    archiveOnDelete: "false"   #false表示在删除PVC时不会对数据进行存档，即删除数据
  ```
  ### mysql 部署
  + `ConfigMap.yaml` 创建配置文件
  ```yaml
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: sks-clusterset-dbc1
    labels:
      app: mysql
  data:
    primary.cnf: |
      # 主节点应用这个配置
      [mysqld]
      log-bin
      default_authentication_plugin= mysql_native_password
    replica.cnf: |
      # 从节点应用这个配置
      [mysqld]
      super-read-only
      default_authentication_plugin= mysql_native_password
  ```
  + `secret.yaml` 创建MySQL密钥 (Opaque类型，data里面的值必须填base64加密后的内容)
  ```yaml
  apiVersion: v1
  kind: Secret
  metadata:
    name: mysql-secret
  type: Opaque
  data:
    password: UGFzc3dvcmQkMTIzNDU2 # Password$123456
    admin-password: UGFzc3dvcmQkMTIzNDU2 # Password$123456
  ```
  + `service.yaml` 创建无头服务(Headless Service)来控制网络域名
  ```yaml
  # Headless service for stable DNS entries of StatefulSet members.
  apiVersion: v1
  kind: Service
  metadata:
    name: mysql
    labels:
      app: mysql
  spec:
    clusterIP: None
    ports:
    - port: 3306
    selector:
      app: mysql
  ---
  # Client service for connecting to any MySQL instance for reads.
  # For writes, you must instead connect to the primary: mysql-0.mysql.
  apiVersion: v1
  kind: Service
  metadata:
    name: mysql-read
    labels:
      app: mysql
  spec:
    ports:
    - port: 3306
      nodePort: 30036
    selector:
      app: mysql
    type: NodePort
  ---
  # 提供外部连接主节点
  apiVersion: v1
  kind: Service
  metadata:
    name: mysql-readwrite
    labels:
      app: mysql
  spec:
    ports:
    - name: mysql
      port: 3306
      nodePort: 30306
    selector:
      statefulset.kubernetes.io/pod-name: mysql-0 
    type: NodePort
  ```
---








