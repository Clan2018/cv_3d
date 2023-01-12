FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

COPY source.list.aliyun /etc/apt/sources.list

RUN apt-get update && apt-get install -y curl gnupg2 lsb-release sudo git vim

RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - \
&&sudo apt-get install -y nodejs
      
RUN npm config set registry https://registry.npm.taobao.org
