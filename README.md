# 基于iBeacon的我去图书馆远程签到

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Version](https://img.shields.io/badge/version-1.0-blue.svg)
![Platform](https://img.shields.io/badge/platform-Linux-lightgrey.svg)

一个使用 C++ 实现的 iBeacon 模拟器，专为需要蓝牙远程签到的场景设计。它允许您在任何支持 BLE 的 Linux 设备上模拟 iBeacon 设备，并可自定义广播的 UUID, Major, 和 Minor 值。

## ✨ 功能特性

- **iBeacon 模拟**: 完整模拟 Apple iBeacon 信号广播。
- **高度自定义**: 支持自定义 UUID, Major, Minor, 和 TX Power 参数。
- **自动化脚本**: 提供一键安装、编译、启动和停止的 shell 脚本。
- **Web 控制界面**: 提供一个简单的 Web 界面，通过浏览器即可控制应用的启动和停止。
- **跨发行版支持**: 自动检测并支持多种主流 Linux 发行版 (Ubuntu, Debian, CentOS, Fedora, Arch 等)。
- **资源智能管理**: 启动时自动接管蓝牙服务，退出时自动恢复，确保系统稳定性。

## 📚 目录

- [iBeacon 蓝牙签到模拟器](#ibeacon-蓝牙签到模拟器)
  - [✨ 功能特性](#-功能特性)
  - [📚 目录](#-目录)
  - [🛠️ 系统要求](#️-系统要求)
  - [🚀 快速开始](#-快速开始)
    - [方式一：Web 界面控制 (推荐)](#方式一web-界面控制-推荐)
    - [方式二：命令行控制](#方式二命令行控制)
  - [⚙️ 配置参数](#️-配置参数)
  - [✅ 测试验证](#-测试验证)
  - [❓ 常见问题](#-常见问题)
  - [🤝 贡献](#-贡献)
  - [📄 许可证](#-许可证)
  - [📞 联系方式](#-联系方式)

## 🛠️ 系统要求

- **操作系统**: Linux (Ubuntu, Debian, CentOS, Fedora, Arch 等)
- **硬件**: 支持 BLE (蓝牙 4.0+) 的蓝牙适配器
- **依赖**: `g++`, `libbluetooth-dev`, `bluez` (可通过 `install.sh` 自动安装)
- **权限**: 需要 `sudo` 权限来访问蓝牙硬件

## 🚀 快速开始

### 方式一：Web 界面控制 (推荐)

这是最简单的方式，通过浏览器即可完成所有操作。

1.  **启动 Web 服务**
    ```bash
    python3 server.py
    ```
    > 如果脚本执行失败，可能需要 `sudo` 权限: `sudo python3 server.py`

2.  **打开浏览器**
    在浏览器中访问 `http://localhost:8000`。

3.  **控制应用**
    - 点击 **"一键启动 (安装并运行)"** 来自动安装依赖并启动服务。
    - 使用 **"启动服务"** 和 **"停止服务"** 按钮来控制 iBeacon 模拟。

### 方式二：命令行控制

适合开发者或喜欢命令行的用户。

1.  **克隆或下载项目**
    ```bash
    git clone https://github.com/your-username/IGOLibrary_remote_sign_in.git
    cd IGOLibrary_remote_sign_in
    ```
    或者解压您下载的源码包。

2.  **安装依赖**
    此脚本会自动检测您的 Linux 发行版并安装必要的依赖。
    ```bash
    sudo ./install.sh
    ```

3.  **编译程序**
    ```bash
    ./build.sh
    ```

4.  **启动程序**
    此脚本会自动处理蓝牙服务的启停。
    ```bash
    sudo ./start.sh
    ```
    程序启动后，会显示 "模拟成功！正在广播..."。

5.  **停止程序**
    按 `Ctrl+C` 或在另一个终端执行以下命令：
    ```bash
    sudo ./stop.sh
    ```

## ⚙️ 配置参数

您可以自定义 iBeacon 的广播参数。

- **文件路径**: `main.cpp`
- **修改内容**: 找到并修改以下变量的值：
  ```cpp
  // --- iBeacon Configuration ---
  const std::string UUID = "FDA50693-A4E2-4FB1-AFCF-C6EB07647825";
  const uint16_t MAJOR = 10199;
  const uint16_t MINOR = 42474;
  const int8_t TX_POWER = -59;
  // ---------------------------
  ```
- **重新编译**: 修改后，需要重新编译才能生效。
  ```bash
  ./build.sh
  ```

## ✅ 测试验证

您可以使用任何支持 iBeacon 的手机 App 来扫描信号。

- **Android**: `Brightbeacon`, `Beacon Scanner`, `nRF Connect`
- **iOS**: `Locate Beacon`, `iBeacon Detector`

**预期扫描结果:**
- **UUID**: `FDA50693-A4E2-4FB1-AFCF-C6EB07647825`
- **Major**: `10199`
- **Minor**: `42474`

## ❓ 常见问题

- **Q: 提示 "错误: 未找到蓝牙适配器"**
  - **A:** 确保您的蓝牙适配器已正确插入。在终端运行 `hciconfig -a` 查看设备。如果是虚拟机，请确保已将蓝牙适配器直通给虚拟机。

- **Q: 提示 "错误: 无法启动广播"**
  - **A:** `start.sh` 脚本会自动处理这个问题。如果手动运行 `beacon_simulator`，请先停止系统蓝牙服务: `sudo systemctl stop bluetooth`。

- **Q: 手机扫描不到信号**
  - **A:** 1) 确认程序终端显示 "模拟成功！正在广播..."。 2) 尝试重启手机蓝牙。 3) 确认您的手机支持 BLE (蓝牙 4.0+)。

## 🤝 贡献

欢迎对本项目做出贡献！如果您有任何想法、建议或发现了 Bug，请随时提交 Pull Request 或创建 Issue。

1.  **Fork** 本项目
2.  创建您的特性分支 (`git checkout -b feature/AmazingFeature`)
3.  提交您的更改 (`git commit -m 'Add some AmazingFeature'`)
4.  推送到分支 (`git push origin feature/AmazingFeature`)
5.  打开一个 **Pull Request**

## 📄 许可证

本项目采用 MIT 许可证。详情请见 [LICENSE](LICENSE) 文件。

## 📞 联系方式

如有任何问题，请通过 GitHub Issues 与我们联系。
