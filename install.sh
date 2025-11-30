#!/bin/bash

# iBeacon 模拟器依赖安装脚本
# 支持 Ubuntu/Debian, CentOS/RHEL, Fedora, Arch Linux

set -e

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  iBeacon 模拟器 - 依赖安装${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# 检查是否以root运行
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}错误: 请使用 sudo 运行此脚本${NC}"
    echo "使用方法: sudo ./install.sh"
    exit 1
fi

# 检测Linux发行版
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    OS_VERSION=$VERSION_ID
else
    echo -e "${RED}错误: 无法检测操作系统${NC}"
    exit 1
fi

echo -e "${YELLOW}检测到操作系统: $OS${NC}"
echo ""

# 根据不同发行版安装依赖
case "$OS" in
    ubuntu|debian)
        echo -e "${YELLOW}正在安装依赖 (Ubuntu/Debian)...${NC}"
        apt-get update
        apt-get install -y \
            build-essential \
            g++ \
            libbluetooth-dev \
            bluez \
            bluez-tools
        ;;

    centos|rhel|rocky|almalinux)
        echo -e "${YELLOW}正在安装依赖 (CentOS/RHEL)...${NC}"
        yum install -y \
            gcc-c++ \
            bluez-libs-devel \
            bluez
        ;;

    fedora)
        echo -e "${YELLOW}正在安装依赖 (Fedora)...${NC}"
        dnf install -y \
            gcc-c++ \
            bluez-libs-devel \
            bluez
        ;;

    arch|manjaro)
        echo -e "${YELLOW}正在安装依赖 (Arch Linux)...${NC}"
        pacman -Sy --noconfirm \
            base-devel \
            bluez \
            bluez-utils
        ;;

    *)
        echo -e "${RED}警告: 未识别的发行版 $OS${NC}"
        echo "请手动安装以下依赖："
        echo "  - g++ 编译器"
        echo "  - libbluetooth-dev (蓝牙开发库)"
        echo "  - bluez (蓝牙协议栈)"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}依赖安装完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "下一步："
echo "  1. 编译程序: ./build.sh"
echo "  2. 启动程序: sudo ./start.sh"
