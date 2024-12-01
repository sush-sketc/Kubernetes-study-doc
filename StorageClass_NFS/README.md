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
sudo yum -y install nfs-utils     #为了测试集群所有节点都安装，如果不需要全部安装则通过添加labels的方式进行调度

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
kubectl  get sa -A |grep nfs
#输出如下
#default           nfs-client-provisioner               0         42s
kubectl  get clusterrole -A|grep nfs
#输出如下
#nfs-client-provisioner-clusterrole                                     2024-11-23T09:33:05Z
kubectl  get clusterrolebindings.rbac.authorization.k8s.io -A|grep nfs  
#输出如下
#nfs-client-provisioner-clusterrolebinding              ClusterRole/nfs-client-provisioner-clusterrole
```
### 6, 使用Deployment创建NFS Provisioners (NFS Provisioner即nfs-client)
[nfs-subdir-external-provisioner](https://github.com/kubernetes-retired/external-storage/tree/master/nfs-client)
> 由于 1.20 版本启用了 selfLink，所以 k8s 1.20+ 版本通过 nfs provisioner 动态生成pv会报错，解决方法如下
> vim /etc/kubernetes/manifests/kube-apiserver.yaml
> - --feature-gates=RemoveSelfLink=false       #添加这一行

```sh
kubectl apply -f nfs-client-provisioner.yaml
#查看pod状态，（如果不正常则需要查看日志定位具体问题）
default        nfs-client-provisioner-d48b5978d-n47fr      1/1     Running   0             22s

#查看
kubectl get storageclasses
#输出如下说明正常
#nfs-client-storageclass   nfs-storage   Delete          Immediate           false                  18m
```
### 7，创建PersistentVolumeClaim和pod并且测试
```sh
kubectl apply -f test-pvc-pod.yaml
```
+ 查看PersistentVolumeClaim,<br>
  ` kubectl get pvc,pv -A -owide`
  ```sh
  #PersistentVolumeClaim输出
  default     persistentvolumeclaim/test-nfs-pvc   Bound    pvc-3e9af1c2-152b-4c88-aafd-8e1db21795ec   1Gi        RWO            nfs-client-storageclass   8s    Filesystem
  #PersistentVolume输出
  persistentvolume/pvc-3e9af1c2-152b-4c88-aafd-8e1db21795ec   1Gi        RWO            Delete           Bound    default/test-nfs-pvc   nfs-client-storageclass            8s    Filesystem
  ```
+ 查看pod
  `kubectl get pod -A -owide |grep task-pv-pod`
  ```sh
  default        task-pv-pod                                 1/1     Running   0             2m26s   10.244.0.10   sketc-ssh.master1
  ```
+ 进入nfs-server查看  
  ```sh
  ls 
  #输出
  /nfs-storage/mysql-storage/default-test-nfs-pvc-pvc-3e9af1c2-152b-4c88-aafd-8e1db21795ec
  #说明：
  #       /nfs-storage/mysql-storage                  -- 设置nfs-server路径
  #       default:                                    -- namespace
  #       test-nfs-pvc:                               -- PersistentVolumeClaim名称     
  #       pvc-3e9af1c2-152b-4c88-aafd-8e1db21795ec    -- PersistentVolume输出名称
  ```
在nfs-server目录`/nfs-storage/mysql-storage/default-test-nfs-pvc-pvc-3e9af1c2-152b-4c88-aafd-8e1db21795ec`添加一条数据，因为在`test-pvc-pod.yaml`文件中定义了吧pod的`/usr/share/nginx/html`目录挂载到了名字为`test-nfs-pvc`的`PersistentVolumeClaim`中，所以在`/nfs-storage/mysql-storage/default-test-nfs-pvc-pvc-3e9af1c2-152b-4c88-aafd-8e1db21795ec`目录下面增加文件就相当于在pod的`/usr/share/nginx/html` 目录下新增文件。
+ 在nfs-server主机目录为`/nfs-storage/mysql-storage/default-test-nfs-pvc-pvc-3e9af1c2-152b-4c88-aafd-8e1db21795ec` 新增文件
```sh
tee /nfs-storage/mysql-storage/default-test-nfs-pvc-pvc-3e9af1c2-152b-4c88-aafd-8e1db21795ec/index.html<<"EOF"
<h3>this is tesing nfs-storageclass pages</h3>
EOF
```
+ 进入pod使用curl命令测试
```sh
#获取pod IP
kubectl get  pods/task-pv-pod -o json| jq -r '.status.podIP'
#10.244.0.10

#进入pod
kubectl exec -it   pods/task-pv-pod sh 

#curl测试
curl 10.244.0.10

#输出如下
<h3>this is tesing nfs-storageclass pages</h3>
#说明成功
```
