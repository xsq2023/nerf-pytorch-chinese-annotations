# 使用 CUDA 11.3 镜像和 Ubuntu 20.04
FROM nvidia/cuda:11.3.1-devel-ubuntu20.04

# 设置环境变量以避免交互式提示
ENV TZ=Asia/Shanghai
ENV DEBIAN_FRONTEND=noninteractive

# 设置默认工作目录
WORKDIR /workspace

# 安装基本工具，包括 SSH 服务和其他系统依赖
RUN apt-get update && apt-get install -y \
    build-essential \
    python3-dev \
    python3-pip \
    python3-venv \
    git \
    wget \
    curl \
    bzip2 \
    ca-certificates \
    libglib2.0-0 \
    libxext6 \
    libxrender-dev \
    libfontconfig1 \
    libx11-dev \
    openssh-server \
    tzdata \
    && ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && dpkg-reconfigure --frontend noninteractive tzdata \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 创建 SSH 服务所需的目录
RUN mkdir /var/run/sshd

# 配置 SSH 默认密码登录（仅用于开发环境）
RUN echo 'root:root' | chpasswd

# 允许 SSH 登录并设置 SSH 服务端口
RUN sed -i 's/#Port 22/Port 63000/' /etc/ssh/sshd_config
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# 禁止 DNS 反向解析，避免 SSH 启动时的延迟
RUN echo "UseDNS no" >> /etc/ssh/sshd_config

# 暴露 SSH 端口
EXPOSE 63000

# 启动 SSH 服务
CMD ["/usr/sbin/sshd", "-D"]