#!/bin/bash

# iBeacon 模拟器打包脚本

set -e

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  iBeacon 模拟器 - 打包${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# 版本号
VERSION="1.0"
DATE=$(date +%Y%m%d)

# 临时目录
TEMP_DIR="ibeacon-simulator"
SOURCE_PACKAGE="ibeacon-simulator-source-v${VERSION}.tar.gz"
BINARY_PACKAGE="ibeacon-simulator-binary-v${VERSION}.tar.gz"

# 清理旧的打包文件
echo -e "${YELLOW}清理旧文件...${NC}"
rm -rf "$TEMP_DIR" "$SOURCE_PACKAGE" "$BINARY_PACKAGE"

# 创建临时目录
mkdir -p "$TEMP_DIR"

# 复制文件
echo -e "${YELLOW}复制文件...${NC}"
cp main.cpp "$TEMP_DIR/"
cp *.sh "$TEMP_DIR/"
cp README.md "$TEMP_DIR/"
cp QUICKSTART.txt "$TEMP_DIR/" 2>/dev/null || true

# 如果存在编译好的文件，也复制
if [ -f "beacon_simulator" ]; then
    cp beacon_simulator "$TEMP_DIR/"
fi

# 打包1: 源码版本（不包含可执行文件）
echo -e "${YELLOW}创建源码包...${NC}"
rm -f "$TEMP_DIR/beacon_simulator" 2>/dev/null || true
tar -czf "$SOURCE_PACKAGE" "$TEMP_DIR"
echo -e "${GREEN}✓ 源码包已创建: $SOURCE_PACKAGE${NC}"

# 打包2: 预编译版本（包含可执行文件）
echo -e "${YELLOW}创建预编译包...${NC}"

# 如果可执行文件不存在，先编译
if [ ! -f "beacon_simulator" ]; then
    echo -e "${YELLOW}  编译可执行文件...${NC}"
    g++ -std=c++20 -o beacon_simulator main.cpp -lbluetooth
fi

# 复制可执行文件
cp beacon_simulator "$TEMP_DIR/"
tar -czf "$BINARY_PACKAGE" "$TEMP_DIR"
echo -e "${GREEN}✓ 预编译包已创建: $BINARY_PACKAGE${NC}"

# 清理临时目录
rm -rf "$TEMP_DIR"

# 显示结果
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}打包完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "生成的文件："
echo ""
echo "1. 源码版本 (需要用户自己编译)"
ls -lh "$SOURCE_PACKAGE" | awk '{printf "   %s  %s\n", $5, $9}'
echo "   适合: 开发者、需要修改参数的用户"
echo "   使用: 解压 -> ./install.sh -> ./build.sh -> sudo ./start.sh"
echo ""
echo "2. 预编译版本 (开箱即用)"
ls -lh "$BINARY_PACKAGE" | awk '{printf "   %s  %s\n", $5, $9}'
echo "   适合: 普通用户、快速部署"
echo "   使用: 解压 -> sudo ./start.sh"
echo ""
echo "注意: 预编译版本在当前系统编译，可能不兼容其他发行版"
echo "      建议提供源码版本供用户在目标系统上编译"
