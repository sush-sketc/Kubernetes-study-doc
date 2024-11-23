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
StorageClass 对象的命名很重要，用户使用这个命名来请求生成一个特定的类。 当创建 StorageClass 对象时，管理员设置 StorageClass 对象的命名和其他参数，一旦创建了对象就不能再对其更新
