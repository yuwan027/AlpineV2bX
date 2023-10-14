#!/bin/sh
# -*- coding: utf-8 -*-
# Define colors
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

# Display the header
echo -e "${green}#####################################"
echo -e "##  AlpineV2bX 一键脚本 By ${plain}${red}Yuwan${plain} ${green}##"
echo -e "#####################################${plain}"

# Display the menu
echo -e "${yellow}输入数字选择对应的操作:${plain}"
echo -e "1. 安装 V2bX"
echo -e "2. 卸载 V2bX"
echo -e "3. 配置 V2bX"
echo -e "4. 重启 V2bX"
#!/bin/bash
echo -e "${green}#####################################${plain}"
# 检查V2bX服务是否已安装
if rc-status | grep -q V2bX; then
    # 如果服务已安装，检查其状态
service_status=$(rc-service V2bX status)
if echo "$service_status" | grep -q "starting" || echo "$service_status" | grep -q "started"; then
    echo -e "${green}#####################################${plain}"
else
    echo -e "${green}#####################################${plain}"
fi
else
    echo -e "${red}V2bX服务未安装。${plain}"
fi
# Read user input
read -p "请输入数字: " choice
echo -e "${green}#####################################${plain}"
# Perform the selected action
case $choice in
    1)
        echo "{green}你选择了安装V2bX{plain}"
        # 更新系统软件源
        apk update
        # 安装一些必要的工具
        apk add unzip wget openrc
        # 创建目录
        mkdir /etc/V2bX
        # 下载V2bX编译好的Alpine压缩包
        wget -P /etc/V2bX https://github.com/InazumaV/V2bX/releases/download/v3.0.0/V2bX-linux-64.zip
        # 解压缩
        unzip /etc/V2bX/V2bX-linux-64.zip -d /etc/V2bX
        # 创建软链接
        ln -s /etc/V2bX/V2bX /usr/bin/V2bX
        # 添加到系统服务
        cat > /etc/init.d/V2bX <<EOF
#!/sbin/openrc-run

depend() {
    need net
}

start() {
    ebegin "Starting V2bX"
    start-stop-daemon --start --exec /usr/bin/V2bX server
    eend $?
}

stop() {
    ebegin "Stopping V2bX"
    start-stop-daemon --stop --exec /usr/bin/V2bX
    eend $?
}

restart() {
    ebegin "Restarting V2bX"
    start-stop-daemon --stop --exec /usr/bin/V2bX
    sleep 1
    start-stop-daemon --start --exec /usr/bin/V2bX server
    eend $?
}
EOF
        # 变成可执行文件
        chmod +x /etc/init.d/V2bX
        # 添加开机自启动
        rc-update add V2bX default

        echo "安装完成"
        # 提示是否自动生成配置文件
        read -p "检测到你为第一次安装V2bX，是否自动直接生成配置文件？(y/n): " if_generate
        if [[ "$if_generate" == "y" || "$if_generate" == "Y" ]]; then
            echo "{red}还没做这方面内容哦,暂时帮你写了个基础的Shadowsocks的配置,请vi /etc/V2bX/config.json自己动手修改对接机场用的那几个东西,理解万岁{plain}"
        cat <<EOL > /etc/V2bX/config.json
{
  "Log": {
    "Level": "info",
    "Output": ""
  },
  "Cores": [
    {
      "Type": "sing",
      "Log": {
        "Level": "error",
        "Timestamp": true
      },
      "DnsConfigPath": "/etc/V2bX/dns.json",
      "NTP": {
        "Enable": true,
        "Server": "time.apple.com",
        "ServerPort": 0
      }
    }
  ],
  "Nodes": [
    {
      "Core": "sing",
      "ApiHost": "http://请修改为机场地址",
      "ApiKey": "请修改为对接密钥",
      "NodeID": 请修改为节点ID注意没有引号,
      "NodeType": "shadowsocks",
      "Timeout": 30,
      "ListenIP": "0.0.0.0",
      "SendIP": "0.0.0.0",
      "EnableProxyProtocol": false,
      "EnableDNS": true,
      "DomainStrategy": "ipv4_only",
      "LimitConfig": {
        "EnableRealtime": false,
        "SpeedLimit": 0,
        "IPLimit": 0,
        "ConnLimit": 0,
        "EnableDynamicSpeedLimit": false,
        "DynamicSpeedLimitConfig": {
          "Periodic": 60,
          "Traffic": 1000,
          "SpeedLimit": 100,
          "ExpireTime": 60
        }
      }
    }
  ]
}
EOL

        else
            exit 0
        fi
        ;;
    2)
        read -p "确定要卸载 V2bX 吗? (y/n): " uninstall_choice

        if [[ "$uninstall_choice" == "y" || "$uninstall_choice" == "Y" ]]; then
            echo "{red}正在卸载 V2bX...{plain}"
            rc-service V2bX stop
            rc-update del V2bX
            rm /etc/init.d/V2bX
            rm /etc/V2bX/ -rf
            echo "{green}卸载成功，如果你想删除此脚本，则退出脚本后运行 'rm /usr/bin/V2bX -f' 进行删除。{plain}"
        else
            echo "{red}已取消卸载{plain}"
        fi
        ;;
    3)
        echo -e "${green}想配置V2bX？想多了。${plain}"
        echo "${red}我还没写这方面的，等等吧，和安装的时候配置的一样给你配置了个基础的ss如果你需要添加更多节点只是加个逗号的事${plain}"
                cat <<EOL > /etc/V2bX/config.json
{
  "Log": {
    "Level": "info",
    "Output": ""
  },
  "Cores": [
    {
      "Type": "sing",
      "Log": {
        "Level": "error",
        "Timestamp": true
      },
      "DnsConfigPath": "/etc/V2bX/dns.json",
      "NTP": {
        "Enable": true,
        "Server": "time.apple.com",
        "ServerPort": 0
      }
    }
  ],
  "Nodes": [
    {
      "Core": "sing",
      "ApiHost": "http://请修改为机场地址",
      "ApiKey": "请修改为对接密钥",
      "NodeID": 请修改为节点ID注意没有引号,
      "NodeType": "shadowsocks",
      "Timeout": 30,
      "ListenIP": "0.0.0.0",
      "SendIP": "0.0.0.0",
      "EnableProxyProtocol": false,
      "EnableDNS": true,
      "DomainStrategy": "ipv4_only",
      "LimitConfig": {
        "EnableRealtime": false,
        "SpeedLimit": 0,
        "IPLimit": 0,
        "ConnLimit": 0,
        "EnableDynamicSpeedLimit": false,
        "DynamicSpeedLimitConfig": {
          "Periodic": 60,
          "Traffic": 1000,
          "SpeedLimit": 100,
          "ExpireTime": 60
        }
      }
    }
  ]
}
EOL
        ;;
    4)
    echo -e "${green}马上帮你${plain}${yellow}冲${plain} ${green}起${plain}"  
    rc-service V2bX restart  
    ;;
    *)
        echo -e "${red}无效的选择${plain}"
        ;;
esac
