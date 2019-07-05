export VIP=$4
export VIP_PORT=$5
export HOST0=$1
export HOST1=$2
export HOST2=$3

envsubst < ./config/config_sample.yaml > ./config/config.yaml  
envsubst < ./config/haproxy_sample.cfg > ./config/haproxy.cfg 
envsubst < ./config/keepalived_sample.conf > ./config/keepalived.conf
envsubst < ./config/keepalived_backup_sample.conf > ./config/keepalived_backup.conf