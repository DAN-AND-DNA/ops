#!/bin/bash


wget https://github.com/protocolbuffers/protobuf/releases/download/v25.1/protoc-25.1-win64.zip

# 先解压
export PATH="$PATH:$HOME/bin"


go install google.golang.org/protobuf/cmd/protoc-gen-go@latest

go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

#syntax = "proto3";

#package greet;
#option go_package="./greet";

#message Request {
#  string ping = 1;
#}

#message Response {
#  string pong = 1;
#}

#service Greet {
#  rpc Ping(Request) returns(Response);
#}

protoc --go_out=. --go-grpc_out=. greet.proto


#使用文档 https://grpc.io/docs/languages/go/quickstart/

# 依赖
#require (
#	google.golang.org/grpc v1.59.0
#	google.golang.org/protobuf v1.31.0
#)