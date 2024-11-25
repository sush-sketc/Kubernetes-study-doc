<font style="background:#F8CED3;color:#70000D">traefik</font>  <font style="background:#DBF1B7;color:#2A4200">traefik</font>

---

### 简介
`<font style="color:rgb(51, 51, 51);">Traefik</font>`<font style="color:rgb(51, 51, 51);">是一个为了让部署微服务更加便捷而诞生的现代HTTP反向代理、负载均衡工具。 它支持多种后台 (</font>`<font style="color:rgb(51, 51, 51);">Docker, Swarm, Kubernetes, Marathon, Mesos, Consul, Etcd, Zookeeper, BoltDB, Rest API, file…</font>`<font style="color:rgb(51, 51, 51);">) 来自动化、动态的应用它的配置文件设置。官方给出流程图如下：</font>

![](https://cdn.nlark.com/yuque/0/2024/png/22052092/1732264113519-3475aa6b-f9a5-4034-9d40-37191100deef.png)

`<font style="color:rgba(0, 0, 0, 0.87);">Traefik</font>`<font style="color:rgba(0, 0, 0, 0.87);"> 基于入口点、路由器、中间件和服务的概念。</font>

<font style="color:rgba(0, 0, 0, 0.87);">主要功能包括动态配置、自动服务发现以及对多种后端和协议的支持。</font>

+ `Providers`用来自动发现平台上的服务，可以是编排工具、容器引擎云提供商或者键值存储。Traefik通过查询Providers的API来查询路由的相关信息，一旦检测到变化，就会动态的更新路由。
+ `Entrypoints`监听传入的流量，是网络的入口点，定义了接受请求的端口(HTTP或者TCP)
+ `Routers`分析请求(host,path,headers,SSL等)，负责将传入的请求连接到可以处理这些请求的服务上去。
+ `Middlewares`中间件，用来修改请求或者根据请求来做出判断，中间件被附件到路由上，是一种在请求发送到服务之前调整请求的一种方法。
+ `Service`将请求转发给应用，负责配置如何最终将处理传入请求的实际服务，Traefik的Service介于Middlewares与KubernetesService之间，可以实现加权负载、流量复制等功能。

---

<font style="color:rgb(48, 49, 51);">当请求Traefik时，请求首先到</font>`<font style="color:rgb(48, 49, 51);">entrypoints</font>`<font style="color:rgb(48, 49, 51);">，然后分析传入的请求，查看他们是否与定义的</font>`<font style="color:rgb(48, 49, 51);">Routers</font>`<font style="color:rgb(48, 49, 51);">匹配。如果匹配，则会通过一系列</font>`<font style="color:rgb(48, 49, 51);">middlewares</font>`<font style="color:rgb(48, 49, 51);">处理，再到</font>`<font style="color:rgb(48, 49, 51);">traefikServices</font>`<font style="color:rgb(48, 49, 51);">上做流量转发，最后请求到</font>`<font style="color:rgb(48, 49, 51);">kubernetes的services上</font>`<font style="color:rgb(48, 49, 51);">。</font>

> Traefik 是一个边缘路由器；这意味着它是你平台的大门，它会拦截并路由每个传入请求：它知道所有的逻辑和规则[，](https://doc.traefik.io/traefik/routing/routers/#rule)确定哪些服务处理哪些请求（基于路径、主机、标头等）
>

![](https://cdn.nlark.com/yuque/0/2024/png/22052092/1732264477247-e18c29eb-74e9-45b4-8b11-37f4c893afd3.png)

## `<font style="color:rgb(48, 49, 51);">Traefik</font>`<font style="color:rgb(48, 49, 51);">组件与</font>`<font style="color:rgb(48, 49, 51);">Nginx</font>`<font style="color:rgb(48, 49, 51);">类比</font>
| 组件名称 | 功能 | nginx相同概念 |
| :--- | :--- | :--- |
| <font style="color:rgb(48, 49, 51);">Providers</font> | <font style="color:rgb(48, 49, 51);">监听路由信息变化，更新路由</font> | <font style="color:rgb(48, 49, 51);">修改nginx配置，reload服务。</font> |
| <font style="color:rgb(48, 49, 51);">Entrypoints</font> | <font style="color:rgb(48, 49, 51);">网络入口，监听传入的流量</font> | <font style="color:rgb(48, 49, 51);">配置文件listen指定监听端口</font> |
| <font style="color:rgb(48, 49, 51);">Routers</font> | <font style="color:rgb(48, 49, 51);">分析传入的请求，匹配规则</font> | <font style="color:rgb(48, 49, 51);">配置文件server_name+location</font> |
| <font style="color:rgb(48, 49, 51);">Middlewares</font> | <font style="color:rgb(48, 49, 51);">中间件，修改请求或响应</font> | <font style="color:rgb(48, 49, 51);">location配置段中添加的缓存、压缩、请求头等配置</font> |
| <font style="color:rgb(48, 49, 51);">Service</font> | <font style="color:rgb(48, 49, 51);">请求转发</font> | <font style="color:rgb(48, 49, 51);">http配置段中的</font><font style="color:rgb(56, 58, 66);background-color:rgb(250, 250, 250);">upstream</font> |


### `<font style="color:rgb(48, 49, 51);">Nginx-Ingress</font>`<font style="color:rgb(48, 49, 51);">和</font>`<font style="color:rgb(48, 49, 51);">traefik</font>`<font style="color:rgb(48, 49, 51);">区别</font>
+ `Ingress Controller`

k8s 是通过一个又一个的 controller 来负责监控、维护集群状态。Ingress Controller 就是监控 Ingress 路由规则的一个变化，然后跟 k8s 的资源操作入口 api-server 进行通信交互。K8s 并没有自带 Ingress Controller，它只是一种标准，具体实现有多种，需要自己单独安装，常用的是 Nginx Ingress Controller 和 Traefik Ingress Controller。

Ingress Controller 收到请求，匹配 Ingress 转发规则，匹配到了就转发到后端 Service，而 Service 可能代表的后端 Pod 有多个，选出一个转发到那个 Pod，最终由那个 Pod 处理请求。

![画板](https://cdn.nlark.com/yuque/0/2024/jpeg/22052092/1732265495856-3e532895-57b5-449f-8a9f-3fa96e78f0f4.jpeg)

### 与`<font style="color:rgb(48, 49, 51);">kubernetes</font>`<font style="color:rgb(48, 49, 51);">交互</font>


