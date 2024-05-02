BASE_PATH="$(dirname $0)"
cd $BASE_PATH
chmod +x testapi

#ulimit -n 100000
ulimit -c unlimited

# 创建一个低权限账号
useradd -r -s /sbin/nologin in_ct_user

docker run \
        --restart=always \
        --name testapi -d \
        --user $(id -u in_ct_user):$(id -g in_ct_user) \
        -w /workdir \
        -p 8080:8080 \
        -v $BASE_PATH:/workdir \
        -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro \
        -e GIN_MODE=release \
        centos ./testapi
