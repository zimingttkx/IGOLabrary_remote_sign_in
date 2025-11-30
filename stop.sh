#!/bin/bash

# iBeacon 模拟器停止脚本

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}正在停止 iBeacon 模拟器...${NC}"

# 检查是否以root运行
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}错误: 请使用 sudo 运行此脚本${NC}"
    echo "使用方法: sudo ./stop.sh"
    exit 1
fi

# 停止所有 beacon_simulator 进程
pkill -f beacon_simulator 2>/dev/null || true
sleep 1

# 检查是否还有残留进程
if pgrep -f beacon_simulator > /dev/null; then
    echo -e "${RED}强制停止残留进程...${NC}"
    pkill -9 -f beacon_simulator 2>/dev/null || true
    sleep 1
fi

# 恢复蓝牙服务
echo -e "${YELLOW}恢复系统蓝牙服务...${NC}"
systemctl start bluetooth 2>/dev/null || true
systemctl enable bluetooth 2>/dev/null || true

echo -e "${GREEN}iBeacon 模拟器已停止${NC}"
echo -e "${GREEN}系统蓝牙服务已恢复${NC}"
