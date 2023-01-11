FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

COPY source.list.aliyun /etc/apt/sources.list

RUN apt-get update && apt-get install -y curl gnupg2 lsb-release sudo git
