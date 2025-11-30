#!/bin/bash

# iBeacon 模拟器编译脚本

set -e

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  iBeacon 模拟器 - 编译${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 检查源代码是否存在
if [ ! -f "main.cpp" ]; then
    echo -e "${RED}错误: 找不到 main.cpp 源代码文件${NC}"
    exit 1
fi

# 检查g++是否安装
if ! command -v g++ &> /dev/null; then
    echo -e "${RED}错误: 未找到 g++ 编译器${NC}"
    echo "请先运行: sudo ./install.sh"
    exit 1
fi

# 检查蓝牙库是否安装
if ! ldconfig -p | grep -q libbluetooth; then
    echo -e "${RED}错误: 未找到 libbluetooth 库${NC}"
    echo "请先运行: sudo ./install.sh"
    exit 1
fi

# 清理旧的编译文件
echo -e "${YELLOW}[1/2] 清理旧文件...${NC}"
rm -f beacon_simulator

# 编译
echo -e "${YELLOW}[2/2] 编译源代码...${NC}"
g++ -std=c++20 -o beacon_simulator main.cpp -lbluetooth

# 检查编译结果
if [ -f "beacon_simulator" ]; then
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}编译成功！${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "可执行文件: beacon_simulator"
    echo "大小: $(du -h beacon_simulator | cut -f1)"
    echo ""
    echo "下一步："
    echo "  启动程序: sudo ./start.sh"
else
    echo -e "${RED}编译失败${NC}"
    exit 1
fi
