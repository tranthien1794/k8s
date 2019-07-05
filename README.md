# Kubernetes Cluster with external etcd cluster

* Yêu cầu tối thiểu 3 node master, worker tùy theo resource

Khai báo ENV trong vars.yaml

## Khởi tạo môi trường 
Chạy trên tất cả các node , cài đặt docker,kubernet, tắt swap, bật ipv4 forward 
Chỉnh sửa trong *install_docker.sh*

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