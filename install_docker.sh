# Install Docker, kubelet, disable swap, enable forward ip.
sudo yum update
sudo timedatectl set-timezone Asia/Ho_Chi_Minh
sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
sudo rpm --import https://download.docker.com/linux/centos/gpg 
sudo yum install docker-ce docker-ce-cli containerd.io -y 
sudo systemctl enable docker
sudo systemctl start docker
sudo cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kube*
EOF

setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=disabled/' /etc/selinux/config

sudo rpm --import https://packages.cloud.google.com/yum/doc/yum-key.gpg
sudo rpm --import https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

sudo systemctl enable --now kubelet

cat << EOF >> /etc/sysctl.conf
net.ipv4.ip_forward=1
net.ipv4.ip_nonlocal_bind=1
EOF

sysctl -p
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

