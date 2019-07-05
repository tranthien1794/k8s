# Kubernetes Cluster with external etcd cluster

* Yêu cầu tối thiểu 3 node master, worker tùy theo resource

* Khai báo ENV trong vars.yaml

## Khởi tạo môi trường 
* Chạy trên tất cả các node , cài đặt docker,kubernet, tắt swap, bật ipv4 forward 
* Chỉnh sửa trong *install_docker.sh*

```
ansible-playbook ansible_preinstall.yaml --extra-vars "HOST="
```

### ETCD Cluster

* Tạo TLS cho etcd

```
ansible-playbook ansible_etcd_1.yaml
```

* Cài đặt etcd trên các node master 

```
ansible-playbook ansible_etcd_2.yaml --extra-vars "HOST="
```

### Kubernetes

* Khởi tạo node đầu tiên 

```
ansible-playbook ansible_master_1.yaml --extra-vars "HOST="
```

* Chạy trên các master còn lại

```
ansible-playbook ansible_master_2.yaml --extra-vars "HOST="
```

* Edit priority 89 trong keepalived trên các node master 

#### Install ingress, dashboard

* Traefik ingress

```
kubectl apply -f service/traefik.yaml
kubectl apply -f service/kubernetes-dashboard.yaml
```

* Tạo secret registry 

```
kubectl --kubeconfig /etc/kubernetes/admin.conf create secret docker-registry registry --docker-server=IP:PORT --docker-username=USER --docker-password=PASS --namespace NAMESPACE
```

* Tạo configmap

```
kubectl create configmap NAME --from-file=FILE --namespace NAMESPACE
```

##### Autoscale service k8s

```
kubectl apply -f service/1.8+/
kubectl autoscale deployment DEPLOYMENT_SERVICE --cpu-percent=5 --min=2 --max=10 -n NAMESPACE
```

###### Các command thông dụng

```
kubectl get pod
kubectl get node
```
