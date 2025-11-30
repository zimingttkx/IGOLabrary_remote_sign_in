#include <iostream>
#include <vector>
#include <cstring>
#include <unistd.h>
#include <errno.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <bluetooth/bluetooth.h>
#include <bluetooth/hci.h>
#include <bluetooth/hci_lib.h>

int main() {
    // 1. 获取并打开蓝牙设备
    int device_id = hci_get_route(NULL);
    if (device_id < 0) {
        std::cerr << "错误: 未找到蓝牙适配器 (请检查硬件或虚拟机直通设置)" << std::endl;
        return -1;
    }

    int device_handle = hci_open_dev(device_id);
    if (device_handle < 0) {
        std::cerr << "错误: 无法打开蓝牙设备 (请使用 sudo 运行)" << std::endl;
        return -1;
    }

    std::cout << ">>> 蓝牙设备已就绪 (ID: " << device_id << ")" << std::endl;

    // 2. 重置蓝牙适配器
    if (hci_send_cmd(device_handle, OGF_HOST_CTL, OCF_RESET, 0, NULL) < 0) {
        std::cerr << "警告: 无法重置适配器 (errno=" << errno << ")" << std::endl;
    } else {
        std::cout << ">>> 蓝牙适配器已重置" << std::endl;
        usleep(500000); // 等待500ms让设备完成重置
    }

    // 3. 重置状态：先关闭广播，防止冲突
    int ret = hci_le_set_advertise_enable(device_handle, 0, 1000);
    if (ret < 0) {
        std::cout << "提示: 关闭广播失败(可能本来就是关闭状态) errno=" << errno << std::endl;
    }

    // 4. 构建 iBeacon 核心数据包
    struct hci_request hci_req;
    le_set_advertising_data_cp adv_data_cp;
    memset(&adv_data_cp, 0, sizeof(adv_data_cp));

    uint8_t segment_length = 0;

    // [Flags]
    adv_data_cp.data[segment_length++] = 0x02;
    adv_data_cp.data[segment_length++] = 0x01;
    adv_data_cp.data[segment_length++] = 0x1A;

    // [Header] Manufacturer Specific Data
    adv_data_cp.data[segment_length++] = 0x1A; // 剩余长度 26字节
    adv_data_cp.data[segment_length++] = 0xFF; // 类型 0xFF

    // [Apple ID] 0x004C
    adv_data_cp.data[segment_length++] = 0x4C;
    adv_data_cp.data[segment_length++] = 0x00;

    // [iBeacon Type]
    adv_data_cp.data[segment_length++] = 0x02;

    // [Data Length]
    adv_data_cp.data[segment_length++] = 0x15; // 21字节

    // ================= 关键数据填充区域 =================

    // 1. UUID: FDA50693-A4E2-4FB1-AFCF-C6EB07647825
    uint8_t uuid[] = {
        0xFD, 0xA5, 0x06, 0x93,
        0xA4, 0xE2,
        0x4F, 0xB1,
        0xAF, 0xCF,
        0xC6, 0xEB, 0x07, 0x64, 0x78, 0x25
    };
    memcpy(&adv_data_cp.data[segment_length], uuid, 16);
    segment_length += 16;

    // 2. Major: 10199 (Decimal) -> 0x27D7 (Hex)
    adv_data_cp.data[segment_length++] = 0x27; // High Byte
    adv_data_cp.data[segment_length++] = 0xD7; // Low Byte

    // 3. Minor: 42474 (Decimal) -> 0xA5EA (Hex)
    adv_data_cp.data[segment_length++] = 0xA5; // High Byte
    adv_data_cp.data[segment_length++] = 0xEA; // Low Byte

    // 4. TX Power: 信号强度校准值 (通常 -59dBm)
    adv_data_cp.data[segment_length++] = 0xC5;

    // ===================================================

    adv_data_cp.length = segment_length;

    // 5. 设置广播参数（重要：必须在设置广播数据后、启用广播前）
    le_set_advertising_parameters_cp adv_params_cp;
    memset(&adv_params_cp, 0, sizeof(adv_params_cp));
    adv_params_cp.min_interval = htobs(0x0800); // 1.28秒
    adv_params_cp.max_interval = htobs(0x0800); // 1.28秒
    adv_params_cp.advtype = 0x03; // ADV_NONCONN_IND (不可连接)
    adv_params_cp.own_bdaddr_type = LE_PUBLIC_ADDRESS;
    adv_params_cp.direct_bdaddr_type = LE_PUBLIC_ADDRESS;
    memset(&adv_params_cp.direct_bdaddr, 0, sizeof(adv_params_cp.direct_bdaddr));
    adv_params_cp.chan_map = 0x07; // 使用全部3个广播信道
    adv_params_cp.filter = 0x00;

    memset(&hci_req, 0, sizeof(hci_req));
    hci_req.ogf = OGF_LE_CTL;
    hci_req.ocf = OCF_LE_SET_ADVERTISING_PARAMETERS;
    hci_req.cparam = &adv_params_cp;
    hci_req.clen = LE_SET_ADVERTISING_PARAMETERS_CP_SIZE;
    hci_req.rparam = NULL;
    hci_req.rlen = 0;
    hci_req.event = EVT_CMD_COMPLETE;

    if (hci_send_req(device_handle, &hci_req, 1000) < 0) {
        std::cerr << "错误: 广播参数设置失败 (errno=" << errno << ")" << std::endl;
        hci_close_dev(device_handle);
        return -1;
    }
    std::cout << ">>> 广播参数配置完成" << std::endl;

    // 6. 发送广播数据配置指令
    memset(&hci_req, 0, sizeof(hci_req));
    hci_req.ogf = OGF_LE_CTL;
    hci_req.ocf = OCF_LE_SET_ADVERTISING_DATA;
    hci_req.cparam = &adv_data_cp;
    hci_req.clen = LE_SET_ADVERTISING_DATA_CP_SIZE;
    hci_req.rparam = NULL;
    hci_req.rlen = 0;
    hci_req.event = EVT_CMD_COMPLETE;

    if (hci_send_req(device_handle, &hci_req, 1000) < 0) {
        std::cerr << "错误: 数据写入失败" << std::endl;
        hci_close_dev(device_handle);
        return -1;
    }

    // 7. 开启广播
    if (hci_le_set_advertise_enable(device_handle, 1, 1000) < 0) {
        std::cerr << "错误: 无法启动广播 (errno=" << errno << ", 错误信息: " << strerror(errno) << ")" << std::endl;
        std::cerr << "可能原因:" << std::endl;
        std::cerr << "  1. 蓝牙适配器不支持BLE广播" << std::endl;
        std::cerr << "  2. 需要更高的权限" << std::endl;
        std::cerr << "  3. 设备被其他程序占用" << std::endl;
        hci_close_dev(device_handle);
        return -1;
    }

    std::cout << ">>> 模拟成功！正在广播目标信号..." << std::endl;
    std::cout << ">>> 目标 Major: 10199 (0x27D7)" << std::endl;
    std::cout << ">>> 目标 Minor: 42474 (0xA5EA)" << std::endl;
    std::cout << ">>> 按 Ctrl+C 停止" << std::endl;

    // 保持进程
    while(true) sleep(10);

    return 0;
}