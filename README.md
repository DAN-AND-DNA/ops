# ops
自己常用的一些linux脚本

## [手动 k8s依赖的镜像源码安装](/gen_kube_install.sh)
## [手动 k8s 部署和启动](/install.sh)
## [安装harbor镜像仓库](/init_harbor.sh)
## [代码仓库 gitea 安装](/init_gitea.sh)
## [备份代码仓库 gitea](/backup_gitea.sh)
## [linux 参数调优和hugepages](/init_env.sh)
## [docker 安装和环境](/init_docker.sh)
## [安装和配置postgresl](/init_postgresql.sh)
## [systemd 托管应用](/init_drilling_cat.sh)
## [安装和配置clickhouse](/init_ck.sh)
## [k8s开发环境](/run_kind_k8s.sh)

```shell
[root@dandev configs]# kind create cluster --config=./kind.yml
Creating cluster "kind" ...
 ✓ Ensuring node image (kindest/node:v1.25.3) 🖼
 ✓ Preparing nodes 📦 📦 📦  
 ✓ Writing configuration 📜 
 ✓ Starting control-plane 🕹️
 ✓ Installing CNI 🔌
 ✓ Installing StorageClass 💾
 ✓ Joining worker nodes 🚜
Set kubectl context to "kind-kind"
You can now use your cluster with:

kubectl cluster-info --context kind-kind

Thanks for using kind! 😊
[root@dandev configs]# kubectl get pods --all-namespaces
NAMESPACE            NAME                                         READY   STATUS                       RESTARTS   AGE
kube-system          coredns-c676cc86f-pbsr8                      1/1     Running                      0          29s
kube-system          coredns-c676cc86f-qsnlh                      1/1     Running                      0          29s
kube-system          etcd-kind-control-plane                      1/1     Running                      0          42s
kube-system          kindnet-mlpm9                                1/1     Running                      0          29s
kube-system          kindnet-tlvj7                                1/1     Running                      0          13s
kube-system          kindnet-xm9ss                                0/1     CreateContainerConfigError   0          13s
kube-system          kube-apiserver-kind-control-plane            1/1     Running                      0          42s
kube-system          kube-controller-manager-kind-control-plane   1/1     Running                      0          42s
kube-system          kube-proxy-9sgkt                             1/1     Running                      0          13s
kube-system          kube-proxy-wsscn                             0/1     ContainerCreating            0          13s
kube-system          kube-proxy-wxwv4                             1/1     Running                      0          29s
kube-system          kube-scheduler-kind-control-plane            1/1     Running                      0          42s
local-path-storage   local-path-provisioner-684f458cdd-kk8zm      1/1     Running                      0          29s
[root@dandev configs]#
[root@dandev configs]#
[root@dandev configs]# kubectl get pods --all-namespaces
NAMESPACE            NAME                                         READY   STATUS    RESTARTS   AGE
kube-system          coredns-c676cc86f-pbsr8                      1/1     Running   0          35s
kube-system          coredns-c676cc86f-qsnlh                      1/1     Running   0          35s
kube-system          etcd-kind-control-plane                      1/1     Running   0          48s
kube-system          kindnet-mlpm9                                1/1     Running   0          35s
kube-system          kindnet-tlvj7                                1/1     Running   0          19s
kube-system          kindnet-xm9ss                                1/1     Running   0          19s
kube-system          kube-apiserver-kind-control-plane            1/1     Running   0          48s
kube-system          kube-controller-manager-kind-control-plane   1/1     Running   0          48s
kube-system          kube-proxy-9sgkt                             1/1     Running   0          19s
kube-system          kube-proxy-wsscn                             1/1     Running   0          19s
kube-system          kube-proxy-wxwv4                             1/1     Running   0          35s
kube-system          kube-scheduler-kind-control-plane            1/1     Running   0          48s
local-path-storage   local-path-provisioner-684f458cdd-kk8zm      1/1     Running   0          35s
[root@dandev configs]# docker container ls
CONTAINER ID   IMAGE                  COMMAND                  CREATED              STATUS              PORTS                                                                                         NAMES
7bbdc8301efb   kindest/node:v1.25.3   "/usr/local/bin/entr…"   About a minute ago   Up About a minute                                                                                                 kind-worker2
0b3dff6cc53a   kindest/node:v1.25.3   "/usr/local/bin/entr…"   About a minute ago   Up About a minute   0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp, 0.0.0.0:3737->3737/tcp, 127.0.0.1:42997->6443/tcp   kind-control-plane
0d3faeff5020   kindest/node:v1.25.3   "/usr/local/bin/entr…"   About a minute ago   Up About a minute                                                                                                 kind-worker
```