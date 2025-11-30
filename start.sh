#!/bin/bash

# iBeacon 模拟器启动脚本
# 自动化完整启动流程

set -e

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   iBeacon 蓝牙签到模拟器 v1.0${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 检查是否以root运行
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}错误: 请使用 sudo 运行此脚本${NC}"
    echo "使用方法: sudo ./start.sh"
    exit 1
fi

# 检查可执行文件是否存在
if [ ! -f "./beacon_simulator" ]; then
    echo -e "${RED}错误: 找不到 beacon_simulator 可执行文件${NC}"
    echo "请先运行: ./build.sh"
    exit 1
fi

# 1. 停止已运行的实例
echo -e "${YELLOW}[1/5] 检查并停止已运行的实例...${NC}"
pkill -f beacon_simulator 2>/dev/null || true
sleep 1

# 2. 停止蓝牙服务
echo -e "${YELLOW}[2/5] 停止系统蓝牙服务...${NC}"
systemctl stop bluetooth 2>/dev/null || true
sleep 1

# 3. 手动启动蓝牙设备
echo -e "${YELLOW}[3/5] 启动蓝牙设备...${NC}"
if ! hciconfig hci0 up 2>/dev/null; then
    echo -e "${RED}警告: 无法启动蓝牙设备 hci0${NC}"
    echo "可能原因："
    echo "  1. 蓝牙适配器未插入"
    echo "  2. 驱动未正确安装"
    echo "  3. 虚拟机USB直通未配置"
fi
sleep 1

# 4. 显示设备信息
echo -e "${YELLOW}[4/5] 蓝牙设备信息:${NC}"
hciconfig hci0 2>/dev/null | head -3 || echo "  无法获取设备信息"
echo ""

# 5. 启动 beacon_simulator
echo -e "${YELLOW}[5/5] 启动 iBeacon 模拟器...${NC}"
echo ""
echo -e "${GREEN}========================================${NC}"

# 运行程序
./beacon_simulator

# 如果程序退出，恢复蓝牙服务
echo ""
echo -e "${YELLOW}正在恢复系统蓝牙服务...${NC}"
systemctl start bluetooth 2>/dev/null || true
systemctl enable bluetooth 2>/dev/null || true
echo -e "${GREEN}已退出${NC}"
