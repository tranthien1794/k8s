export VIP=$4
export VIP_PORT=$5
export HOST0=$1
export HOST1=$2
export HOST2=$3
cd etcd 
ETCDHOSTS=(${HOST0} ${HOST1} ${HOST2})
NAMES=("infra0" "infra1" "infra2")

for i in "${!ETCDHOSTS[@]}"; do

HOST=${ETCDHOSTS[$i]}
NAME=${NAMES[$i]}

cat << EOF > etcd-${HOST}.service
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
ExecStart=/usr/local/bin/etcd \
  --name ${NAME} \
  --cert-file=/etc/etcd/kubernetes.pem \
  --key-file=/etc/etcd/kubernetes-key.pem \
  --peer-cert-file=/etc/etcd/kubernetes.pem \
  --peer-key-file=/etc/etcd/kubernetes-key.pem \
  --trusted-ca-file=/etc/etcd/ca.pem \
  --peer-trusted-ca-file=/etc/etcd/ca.pem \
  --peer-client-cert-auth \
  --client-cert-auth \
  --initial-advertise-peer-urls https://${HOST}:2380 \
  --listen-peer-urls https://${HOST}:2380 \
  --listen-client-urls https://${HOST}:2379,http://127.0.0.1:2379 \
  --advertise-client-urls https://${HOST}:2379 \
  --initial-cluster-token etcd-cluster-0 \
  --initial-cluster ${NAMES[0]}=https://${ETCDHOSTS[0]}:2380,${NAMES[1]}=https://${ETCDHOSTS[1]}:2380,${NAMES[2]}=https://${ETCDHOSTS[2]}:2380 \
  --initial-cluster-state new \
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
done


./cfssl_linux-amd64 gencert -initca ca-csr.json | ./cfssljson_linux-amd64 -bare ca
./cfssl_linux-amd64 gencert \
-ca=ca.pem \
-ca-key=ca-key.pem \
-config=ca-config.json \
-hostname=worker1,worker2,worker3,w1,w3,w3,${VIP},${HOST0},${HOST1},${HOST2},127.0.0.1,kubernetes.default \
-profile=kubernetes kubernetes-csr.json | \
./cfssljson_linux-amd64 -bare kubernetes
#etcdctl --ca-file /etc/etcd/ca.pem --cert-file /etc/etcd/kubernetes.pem --key-file /etc/etcd/kubernetes-key.pem --endpoints=https://${HOST0}:2379,https://${HOST1}:2379,https://${HOST2}:2379 cluster-health
