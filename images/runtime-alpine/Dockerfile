FROM alpine:3.14.0
RUN echo "http://mirrors.ustc.edu.cn/alpine/v3.14/main/" > /etc/apk/repositories
RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

RUN apk add --no-cache tzdata ca-certificates && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone && echo "hosts: files dns" > /etc/nsswitch.conf
