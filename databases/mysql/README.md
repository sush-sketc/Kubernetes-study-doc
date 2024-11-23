 <p align="left">
<b><i>Kubernetes deployment of MySQL cluster </i></b>
</p>
<p align="left">
<a herf="https://img.shields.io/badge/CNCF-Kubernetes-informational?style=flat&logo=Kubernetes&color=777BB4"><img src="https://img.shields.io/badge/CNCF-Kubernetes-informational?style=flat&logo=Kubernetes&color=777BB4"></a>
<a href="https://img.shields.io/github/issues/sush-sketc/Kubernetes-study-doc"><img src="https://img.shields.io/github/issues/sush-sketc/Kubernetes-study-doc"></a>
<a href="https://img.shields.io/github/license/sush-sketc/Kubernetes-study-doc"><img src="https://img.shields.io/github/license/sush-sketc/Kubernetes-study-doc"></a>
<a herf="https://img.shields.io/badge/mysql-db-v1?style=flat-square&logo=MySQL&labelColor=hsl&color=rgb"><img src="https://img.shields.io/badge/mysql-db-v1?style=flat-square&logo=MySQL&labelColor=hsl&color=rgb"></a>
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
| MySQL | 8.0.18 |
| xtrabackup | 8.0.9 |

> <font color=red> 注意: MySQL和xtrabacbup版本必须一致</font> <br>

