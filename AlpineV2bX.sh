#!/bin/sh
# -*- coding: utf-8 -*-
# Define colors
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

# Display the header
echo -e "${green}#####################################"
echo -e "######  AlpineV2bX 基于Unoffical V2board配套V2bX ######"
echo -e "#####################################${plain}"

# 菜单
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
    echo -e "${green}V2bX运行中${plain}"
else
    echo -e "${red}V2bX未在运行${plain}"
fi
else
    echo -e "${red}V2bX服务未安装。${plain}"
fi
# Read user input
read -p "请输入数字: " choice
echo -e "${green}#####################################${plain}"
# Perform the selected action
case "$choice" in
1)

echo -e "${green}你选择了安装V2bX${plain}"
        # 更新系统软件源
        apk update
        # 安装一些必要的工具
        apk add unzip wget curl openrc jq bash
        # 创建目录
        mkdir /etc/V2bX
        # 检测架构
        arch=$(arch)

        if [[ $arch == "x86_64" || $arch == "x64" || $arch == "amd64" ]]; then
            arch="64"
        elif [[ $arch == "aarch64" || $arch == "arm64" ]]; then
            arch="arm64-v8a"
        elif [[ $arch == "s390x" ]]; then
            arch="s390x"
        else
            arch="64"
            echo -e "${red}检测架构失败，使用默认架构: ${arch}${plain}"
        fi
        # 下载编译好的V2bX (2024/1/24更新为Xiao的修改版V2bX)
        if  [ $# == 0 ] ;then
                last_version=$(curl -Ls "https://api.github.com/repos/wyx2685/V2bX/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
                if [[ ! -n "$last_version" ]]; then
                    echo -e "${red}检测 V2bX 版本失败，默认采用2024年1月28日版本${plain}"
                    last_version=v0.0.1-20240128
                fi
                echo -e "${green}检测到 V2bX 最新版本：${last_version}，开始安装${plain}"
                wget -q -N --no-check-certificate -O '/etc/V2bX/V2bX-linux.zip' https://github.com/wyx2685/V2bX/releases/download/${last_version}/V2bX-linux-${arch}.zip
                if [[ $? -ne 0 ]]; then
                    echo -e "${red}下载 V2bX 失败，请确保你的服务器能够下载 Github 的文件${plain}"
                    exit 1
                fi
            fi
 
                unzip /etc/V2bX/V2bX-linux.zip -d /etc/V2bX
# 自动更新并验证geosite&geoip的哈希
GEOIP_DEFAULT_VERSION="202402010040"
GEOSITE_DEFAULT_VERSION="20240131105845"

LASTEST_TAG_geoip="$(curl -sL "https://api.github.com/repos/v2fly/geoip/releases" | jq -r ".[0].tag_name")"
LASTEST_TAG_geosite="$(curl -sL "https://api.github.com/repos/v2fly/domain-list-community/releases" | jq -r ".[0].tag_name")"
# 检查是否因为 API 速率限制而失败
if [[ "$LASTEST_TAG_geoip" != "20"* ]]; then
    echo -e "${red}您的服务器受到Github API速率限制，采用默认老版本${plain}"
LASTEST_TAG_geoip=$GEOIP_DEFAULT_VERSION
LASTEST_TAG_geosite=$GEOSITE_DEFAULT_VERSION
else
echo -e "${green}当前geoip.dat文件更新时间: $LASTEST_TAG_geoip ${plain}"
echo -e "${green}当前geosite.dat文件更新时间: $LASTEST_TAG_geosite ${plain}"
fi

GEOIP_FILE="/etc/V2bX/geoip.dat"
GEOSITE_FILE="/etc/V2bX/geosite.dat"

echo -e "正在下载 ${GEOIP_FILE}..."
curl -L  -o ${GEOIP_FILE} "https://github.com/v2fly/geoip/releases/download/${LASTEST_TAG_geoip}/geoip.dat"

echo -e "正在下载 ${GEOSITE_FILE}..."
curl -L -o ${GEOSITE_FILE} "https://github.com/v2fly/domain-list-community/releases/download/${LASTEST_TAG_geosite}/dlc.dat" 

echo -e "正在验证哈希值..."
GEOIP_HASH="$(curl -sL "https://github.com/v2fly/geoip/releases/download/${LASTEST_TAG_geoip}/geoip.dat.sha256sum" | awk -F ' ' '{print $1}')"
GEOSITE_HASH="$(curl -sL "https://github.com/v2fly/domain-list-community/releases/download/${LASTEST_TAG_geosite}/dlc.dat.sha256sum" | awk -F ' ' '{print $1}')"

GEOIP_CHECKSUM="$(sha256sum ${GEOIP_FILE} | awk -F ' ' '{print $1}')"
GEOSITE_CHECKSUM="$(sha256sum ${GEOSITE_FILE} | awk -F ' ' '{print $1}')"

if [ "$GEOIP_CHECKSUM" == "$GEOIP_HASH" ]; then
    echo "已验证 ${GEOIP_FILE} 的哈希值."
else
    echo -e "${GEOIP_FILE} 的哈希值与云端不匹配，能用就行，跳过验证。"
fi

if [ "$GEOSITE_CHECKSUM" == "$GEOSITE_HASH" ]; then
    echo "已验证 ${GEOSITE_FILE} 的哈希值."
else
    echo -e "${GEOSITE_FILE} 的哈希值与云端不匹配，能用就行，跳过验证。"
fi


        # 创建软链接
        ln -s /etc/V2bX/V2bX /usr/bin/V2bX
        # 添加到系统服务
        cat > /etc/init.d/V2bX <<EOF
#!/sbin/openrc-run

depend() {
    need net
    after sshd
    after crond
}

start() {
    ebegin "Starting V2bX"
    start-stop-daemon --start --exec /usr/bin/V2bX server --background
    eend $?
}

stop() {
    ebegin "Stopping V2bX"
    start-stop-daemon --stop --exec /usr/bin/V2bX server
    eend $?
}

restart() {
    ebegin "Restarting V2bX"
    start-stop-daemon --stop --exec /usr/bin/V2bX server
    sleep 1
    start-stop-daemon --start --exec /usr/bin/V2bX server --background
    eend $?
}
EOF
        # 给权限
        chmod +x /etc/init.d/V2bX
        # 添加开机自启动
        rc-update add V2bX default

        echo "安装完成"
        # 提示是否自动生成配置文件
		read -p "检测到你为第一次安装V2bX，是否自动直接生成配置文件？(y/n): " if_generate		

	case "$if_generate" in
	y|Y )
		# 核心选择
		read -rp "请输入机场网址(需要带上https或http)：" ApiHost
        read -rp "请输入面板对接API Key：" ApiKey
		echo -e "${green}请选择节点核心类型：${plain}"
    echo -e "${green}1. xray${plain}"
    echo -e "${green}2. singbox${plain}"
    read -rp "请输入：" core_type
	
	# 根据核心类型生成core部分的配置
    if [ "$core_type" = 1 ]; then
        core_config="[
        {
            \"Type\": \"xray\",
            \"Log\": {
                \"Level\": \"error\",
                \"ErrorPath\": \"/etc/V2bX/error.log\"
            },
            \"OutboundConfigPath\": \"/etc/V2bX/custom_outbound.json\",
            \"RouteConfigPath\": \"/etc/V2bX/route.json\"
        }]"
    elif [ "$core_type" = 2 ]; then
        core_config="[
        {
            \"Type\": \"sing\",
            \"Log\": {
                \"Level\": \"error\",
                \"Timestamp\": true
            },
            \"NTP\": {
                \"Enable\": false,
                \"Server\": \"time.apple.com\",
                \"ServerPort\": 0
            },
            \"OriginalPath\": \"/etc/V2bX/sing_origin.json\"
        }]"
		fi
		#根据核心类型生成node部分的配置
		if [ "$core_type" == "1" ]; then
        core="xray"
        core_xray=true
    elif [ "$core_type" == "2" ]; then
        core="sing"
        core_sing=true
    else
        echo "无效的选择。请选择 1 或 2。"
    fi
	
	while true; do
        read -rp "请输入节点Node ID：" NodeID
        # 判断NodeID是否为正整数
        if [[ "$NodeID" =~ ^[0-9]+$ ]]; then
            break  # 输入正确，退出循环
        else
            echo "错误：请输入正确的数字作为Node ID。"
        fi
    done
	
	echo -e "${yellow}请选择节点传输协议：${plain}"
    echo -e "${green}1. Shadowsocks${plain}"
    echo -e "${green}2. Vless${plain}"
    echo -e "${green}3. Vmess${plain}"
    echo -e "${green}4. Hysteria${plain}"
    echo -e "${green}5. Hysteria2${plain}"
    echo -e "${green}6. Tuic${plain}"
    echo -e "${green}7. Trojan${plain}"
    read -rp "请输入：" NodeType
    case "$NodeType" in
        1 ) NodeType="shadowsocks" ;;
        2 ) NodeType="vless" ;;
        3 ) NodeType="vmess" ;;
        4 ) NodeType="hysteria" ;;
        5 ) NodeType="hysteria2" ;;
        6 ) NodeType="tuic" ;;
        7 ) NodeType="trojan" ;;
        * ) NodeType="shadowsocks" ;;
    esac
	
	read -rp "请你自行判断是否需要证书(y/n)" needcert
	if [ "${needcert,,}" = "y" ]; then
        echo -e "${yellow}请选择证书申请模式：${plain}"
        echo -e "${green}1. http模式自动申请，提前整明白80端口${plain}"
        echo -e "${green}2. dns模式自动申请，NAT常用${plain}"
        echo -e "${green}3. self模式，自签证书或提供已有证书文件${plain}"
		echo -e "${green}4. 输入其他数字取消配置证书${plain}"
        read -rp "请输入：" certmode
		echo -e "${green}你进入了$certmode模式${plain}"
        read -rp "请输入节点证书域名(example.com)]：" certdomain
		
		case "$certmode" in 
        1 )  
cert_config=$(cat <<EOF
"CertConfig": {
	"CertMode": "http",
	"RejectUnknownSni": false,
	"CertDomain": "$certdomain",
	"CertFile": "/etc/V2bX/fullchain.cer",
	"KeyFile": "/etc/V2bX/cert.key",
	"Email": "v2bx@github.com",
	"Provider": "cloudflare",
	"DNSEnv": {
		"EnvName": "env1"
			  }
			}
EOF
)
		;;
        2 )
            read -rp "CF邮箱：" cfemail
            read -rp "CF Global API KEY：" cfapi
cert_config=$(cat <<EOF
"CertConfig": {
    "CertMode": "dns",
    "RejectUnknownSni": false,
    "CertDomain": "$certdomain",
    "CertFile": "/etc/V2bX/fullchain.cer",
    "KeyFile": "/etc/V2bX/cert.key",
    "Email": "v2bx@github.com",
    "Provider": "cloudflare",
    "DNSEnv": {
        "CLOUDFLARE_EMAIL": "$cfemail",
        "CLOUDFLARE_API_KEY": "$cfapi"                
              }
            }
EOF
)
		;;
        3 )
            read -rp "CertFile绝对路径：" CertFile
            read -rp "KeyFile绝对路径：" KeyFile
cert_config=$(cat <<EOF
"CertConfig": {
    "CertMode": "self",
    "RejectUnknownSni": false,
    "CertDomain": "$certdomain",
    "CertFile": "$CertFile",
    "KeyFile": "$KeyFile"            
             }
EOF
)
        ;;
		esac
		
		else
		cert_config=""
		fi
	
			# 检查IPV6情况
	if ip -6 addr | grep -q "inet6"; then
        listen_ip="::"  # 支持 IPv6
		echo -e "${green}您的服务器支持IPV6，已自动监听${plain}"
    else
        listen_ip="0.0.0.0"  # 不支持 IPv6
		echo -e "${green}您的服务器不支持IPV6${plain}"
	fi
	
		case "$core_type" in
	1 )
    node_config=$(cat <<EOF
            "Core": "$core",
            "ApiHost": "$ApiHost",
            "ApiKey": "$ApiKey",
            "NodeID": $NodeID,
            "NodeType": "$NodeType",
            "Timeout": 30,
            "ListenIP": "0.0.0.0",
            "SendIP": "0.0.0.0",
            "DeviceOnlineMinTraffic": 100,
            "EnableProxyProtocol": false,
            "EnableUot": true,
            "EnableTFO": true,
            "DNSType": "UseIPv4",
            $cert_config
EOF
)
	;;
	2 )
    node_config=$(cat <<EOF
    "Core": "$core",
    "ApiHost": "$ApiHost",
    "ApiKey": "$ApiKey",
    "NodeID": $NodeID,
    "NodeType": "$NodeType",
    "Timeout": 30,
    "ListenIP": "$listen_ip",
    "SendIP": "0.0.0.0",
    "DeviceOnlineMinTraffic": 100,
    "TCPFastOpen": true,
    "SniffEnabled": true,
    "EnableDNS": true,
    $cert_config
EOF
)
	;;
esac

	# 切换到配置文件目录
    cd /etc/V2bX
    
    # 备份旧的配置文件
    mv config.json config.json.bak

    # 创建 config.json 文件
    cat <<EOF > /etc/V2bX/config.json
{
    "Log": {
        "Level": "error",
        "Output": ""
    },
    "Cores": $core_config,
    "Nodes": [{$node_config}]
}
EOF
    # 创建 custom_outbound.json 文件
    cat <<EOF > /etc/V2bX/custom_outbound.json
    [
        {
            "tag": "IPv4_out",
            "protocol": "freedom",
            "settings": {
                "domainStrategy": "UseIPv4v6"
            }
        },
        {
            "tag": "IPv6_out",
            "protocol": "freedom",
            "settings": {
                "domainStrategy": "UseIPv6"
            }
        },
        {
            "protocol": "blackhole",
            "tag": "block"
        }
    ]
EOF
    
    # 创建 route.json 文件
    cat <<EOF > /etc/V2bX/route.json
    {
        "domainStrategy": "AsIs",
        "rules": [
            {
                "type": "field",
                "outboundTag": "block",
                "ip": [
                    "geoip:private",
                    "geoip:cn"
                ]
            },
            {
                "domain": [
                    "geosite:google"
                ],
                "outboundTag": "IPv4_out",
                "type": "field"
            },
            {
                "type": "field",
                "outboundTag": "block",
                "domain": [
                    "geosite:cn"
                ]
            },
            {
                "type": "field",
                "outboundTag": "block",
                "domain": [
                    "regexp:(api|ps|sv|offnavi|newvector|ulog.imap|newloc)(.map|).(baidu|n.shifen).com",
                    "regexp:(.+.|^)(360|so).(cn|com)",
                    "regexp:(Subject|HELO|SMTP)",
                    "regexp:(torrent|.torrent|peer_id=|info_hash|get_peers|find_node|BitTorrent|announce_peer|announce.php?passkey=)",
                    "regexp:(^.@)(guerrillamail|guerrillamailblock|sharklasers|grr|pokemail|spam4|bccto|chacuo|027168).(info|biz|com|de|net|org|me|la)",
                    "regexp:(.?)(xunlei|sandai|Thunder|XLLiveUD)(.)",
                    "regexp:(..||)(dafahao|mingjinglive|botanwang|minghui|dongtaiwang|falunaz|epochtimes|ntdtv|falundafa|falungong|wujieliulan|zhengjian).(org|com|net)",
                    "regexp:(ed2k|.torrent|peer_id=|announce|info_hash|get_peers|find_node|BitTorrent|announce_peer|announce.php?passkey=|magnet:|xunlei|sandai|Thunder|XLLiveUD|bt_key)",
                    "regexp:(.+.|^)(360).(cn|com|net)",
                    "regexp:(.*.||)(guanjia.qq.com|qqpcmgr|QQPCMGR)",
                    "regexp:(.*.||)(rising|kingsoft|duba|xindubawukong|jinshanduba).(com|net|org)",
                    "regexp:(.*.||)(netvigator|torproject).(com|cn|net|org)",
                    "regexp:(..||)(visa|mycard|gash|beanfun|bank).",
                    "regexp:(.*.||)(gov|12377|12315|talk.news.pts.org|creaders|zhuichaguoji|efcc.org|cyberpolice|aboluowang|tuidang|epochtimes|zhengjian|110.qq|mingjingnews|inmediahk|xinsheng|breakgfw|chengmingmag|jinpianwang|qi-gong|mhradio|edoors|renminbao|soundofhope|xizang-zhiye|bannedbook|ntdtv|12321|secretchina|dajiyuan|boxun|chinadigitaltimes|dwnews|huaglad|oneplusnews|epochweekly|cn.rfi).(cn|com|org|net|club|net|fr|tw|hk|eu|info|me)",
                    "regexp:(.*.||)(miaozhen|cnzz|talkingdata|umeng).(cn|com)",
                    "regexp:(.*.||)(mycard).(com|tw)",
                    "regexp:(.*.||)(gash).(com|tw)",
                    "regexp:(.bank.)",
                    "regexp:(.*.||)(pincong).(rocks)",
                    "regexp:(.*.||)(taobao).(com)",
                    "regexp:(.*.||)(laomoe|jiyou|ssss|lolicp|vv1234|0z|4321q|868123|ksweb|mm126).(com|cloud|fun|cn|gs|xyz|cc)",
                    "regexp:(flows|miaoko).(pages).(dev)"
                ]
            },
            {
                "type": "field",
                "outboundTag": "block",
                "ip": [
                    "127.0.0.1/32",
                    "10.0.0.0/8",
                    "fc00::/7",
                    "fe80::/10",
                    "172.16.0.0/12"
                ]
            },
            {
                "type": "field",
                "outboundTag": "block",
                "protocol": [
                    "bittorrent"
                ]
            }
        ]
    }
EOF

    # 创建 sing_origin.json 文件           
    cat <<EOF > /etc/V2bX/sing_origin.json
{
  "outbounds": [
    {
      "tag": "direct",
      "type": "direct",
      "domain_strategy": "prefer_ipv4"
    },
    {
      "type": "block",
      "tag": "block"
    }
  ],
  "route": {
    "rules": [
      {
        "outbound": "block",
        "geoip": [
          "private"
        ]
      },
      {
        "geosite": [
          "google"
        ],
        "outbound": "direct"
      },
      {
        "geosite": [
          "cn"
        ],
        "outbound": "block"
      },
      {
        "geoip": [
          "cn"
        ],
        "outbound": "block"
      },
      {
        "domain_regex": [
            "(api|ps|sv|offnavi|newvector|ulog.imap|newloc)(.map|).(baidu|n.shifen).com",
            "(.+.|^)(360|so).(cn|com)",
            "(Subject|HELO|SMTP)",
            "(torrent|.torrent|peer_id=|info_hash|get_peers|find_node|BitTorrent|announce_peer|announce.php?passkey=)",
            "(^.@)(guerrillamail|guerrillamailblock|sharklasers|grr|pokemail|spam4|bccto|chacuo|027168).(info|biz|com|de|net|org|me|la)",
            "(.?)(xunlei|sandai|Thunder|XLLiveUD)(.)",
            "(..||)(dafahao|mingjinglive|botanwang|minghui|dongtaiwang|falunaz|epochtimes|ntdtv|falundafa|falungong|wujieliulan|zhengjian).(org|com|net)",
            "(ed2k|.torrent|peer_id=|announce|info_hash|get_peers|find_node|BitTorrent|announce_peer|announce.php?passkey=|magnet:|xunlei|sandai|Thunder|XLLiveUD|bt_key)",
            "(.+.|^)(360).(cn|com|net)",
            "(.*.||)(guanjia.qq.com|qqpcmgr|QQPCMGR)",
            "(.*.||)(rising|kingsoft|duba|xindubawukong|jinshanduba).(com|net|org)",
            "(.*.||)(netvigator|torproject).(com|cn|net|org)",
            "(..||)(visa|mycard|gash|beanfun|bank).",
            "(.*.||)(gov|12377|12315|talk.news.pts.org|creaders|zhuichaguoji|efcc.org|cyberpolice|aboluowang|tuidang|epochtimes|zhengjian|110.qq|mingjingnews|inmediahk|xinsheng|breakgfw|chengmingmag|jinpianwang|qi-gong|mhradio|edoors|renminbao|soundofhope|xizang-zhiye|bannedbook|ntdtv|12321|secretchina|dajiyuan|boxun|chinadigitaltimes|dwnews|huaglad|oneplusnews|epochweekly|cn.rfi).(cn|com|org|net|club|net|fr|tw|hk|eu|info|me)",
            "(.*.||)(miaozhen|cnzz|talkingdata|umeng).(cn|com)",
            "(.*.||)(mycard).(com|tw)",
            "(.*.||)(gash).(com|tw)",
            "(.bank.)",
            "(.*.||)(pincong).(rocks)",
            "(.*.||)(taobao).(com)",
            "(.*.||)(laomoe|jiyou|ssss|lolicp|vv1234|0z|4321q|868123|ksweb|mm126).(com|cloud|fun|cn|gs|xyz|cc)",
            "(flows|miaoko).(pages).(dev)"
        ],
        "outbound": "block"
      },
      {
        "outbound": "direct",
        "network": [
          "udp","tcp"
        ]
      }
    ]
  }
}
EOF
echo -e "${green}V2bX 配置文件生成完成,正在重新启动服务,您原先的配置被被分到config.json.bak${plain}"	
echo -e "${green}再次运行 bash AlpineV2bX.sh${plain}"
rc-service V2bX restart
	;;
*)
echo -e "${red}不生成配置,退出脚本,再次运行 bash AlpineV2bX.sh${plain}"
exit 0
	esac
;;
2)

read -p "确定要卸载 V2bX 吗? (y/n): " uninstall_choice

        if [[ "$uninstall_choice" == "y" || "$uninstall_choice" == "Y" ]]; then
            echo "{red}正在卸载 V2bX...{plain}"
            rc-service V2bX stop
            rc-update del V2bX
            rm /etc/init.d/V2bX
            rm /etc/V2bX/ -rf
            echo "{green}卸载成功，如果你想删除此脚本，则退出脚本后运行 'rm /usr/bin/V2bX -f' 'rm AlpineV2bX.sh -f' 进行删除。{plain}"
        else
            echo "{red}已取消卸载{plain}"
        fi

;;
3)

		# 核心选择
		read -rp "请输入机场网址(需要带上https:\\或http:\\)：" ApiHost
        read -rp "请输入面板对接API Key：" ApiKey
		echo -e "${green}请选择节点核心类型：${plain}"
    echo -e "${green}1. xray${plain}"
    echo -e "${green}2. singbox${plain}"
    read -rp "请输入：" core_type
	
	# 根据核心类型生成core部分的配置
    if [ "$core_type" = 1 ]; then
        core_config="[
        {
            \"Type\": \"xray\",
            \"Log\": {
                \"Level\": \"error\",
                \"ErrorPath\": \"/etc/V2bX/error.log\"
            },
            \"OutboundConfigPath\": \"/etc/V2bX/custom_outbound.json\",
            \"RouteConfigPath\": \"/etc/V2bX/route.json\"
        }]"
    elif [ "$core_type" = 2 ]; then
        core_config="[
        {
            \"Type\": \"sing\",
            \"Log\": {
                \"Level\": \"error\",
                \"Timestamp\": true
            },
            \"NTP\": {
                \"Enable\": false,
                \"Server\": \"time.apple.com\",
                \"ServerPort\": 0
            },
            \"OriginalPath\": \"/etc/V2bX/sing_origin.json\"
        }]"
		fi
		#根据核心类型生成node部分的配置
		if [ "$core_type" == "1" ]; then
        core="xray"
        core_xray=true
    elif [ "$core_type" == "2" ]; then
        core="sing"
        core_sing=true
    else
        echo "无效的选择。请选择 1 或 2。"
    fi
	
	while true; do
        read -rp "请输入节点Node ID：" NodeID
        # 判断NodeID是否为正整数
        if [[ "$NodeID" =~ ^[0-9]+$ ]]; then
            break  # 输入正确，退出循环
        else
            echo "错误：请输入正确的数字作为Node ID。"
        fi
    done
	
	echo -e "${yellow}请选择节点传输协议：${plain}"
    echo -e "${green}1. Shadowsocks${plain}"
    echo -e "${green}2. Vless${plain}"
    echo -e "${green}3. Vmess${plain}"
    echo -e "${green}4. Hysteria${plain}"
    echo -e "${green}5. Hysteria2${plain}"
    echo -e "${green}6. Tuic${plain}"
    echo -e "${green}7. Trojan${plain}"
    read -rp "请输入：" NodeType
    case "$NodeType" in
        1 ) NodeType="shadowsocks" ;;
        2 ) NodeType="vless" ;;
        3 ) NodeType="vmess" ;;
        4 ) NodeType="hysteria" ;;
        5 ) NodeType="hysteria2" ;;
        6 ) NodeType="tuic" ;;
        7 ) NodeType="trojan" ;;
        * ) NodeType="shadowsocks" ;;
    esac
	
	read -rp "请你自行判断是否需要证书(y/n)" needcert
	if [ "${needcert,,}" = "y" ]; then
        echo -e "${yellow}请选择证书申请模式：${plain}"
        echo -e "${green}1. http模式自动申请，提前整明白80端口${plain}"
        echo -e "${green}2. dns模式自动申请，NAT常用${plain}"
        echo -e "${green}3. self模式，自签证书或提供已有证书文件${plain}"
		echo -e "${green}4. 输入其他数字取消配置证书${plain}"
        read -rp "请输入：" certmode
		echo -e "${green}你进入了$certmode模式${plain}"
        read -rp "请输入节点证书域名(example.com)]：" certdomain
		
		case "$certmode" in 
        1 )  
cert_config=$(cat <<EOF
"CertConfig": {
	"CertMode": "http",
	"RejectUnknownSni": false,
	"CertDomain": "$certdomain",
	"CertFile": "/etc/V2bX/fullchain.cer",
	"KeyFile": "/etc/V2bX/cert.key",
	"Email": "v2bx@github.com",
	"Provider": "cloudflare",
	"DNSEnv": {
		"EnvName": "env1"
			  }
			}
EOF
)
		;;
        2 )
            read -rp "CF邮箱：" cfemail
            read -rp "CF Global API KEY：" cfapi
cert_config=$(cat <<EOF
"CertConfig": {
    "CertMode": "dns",
    "RejectUnknownSni": false,
    "CertDomain": "$certdomain",
    "CertFile": "/etc/V2bX/fullchain.cer",
    "KeyFile": "/etc/V2bX/cert.key",
    "Email": "v2bx@github.com",
    "Provider": "cloudflare",
    "DNSEnv": {
        "CLOUDFLARE_EMAIL": "$cfemail",
        "CLOUDFLARE_API_KEY": "$cfapi"                
              }
            }
EOF
)
		;;
        3 )
            read -rp "CertFile绝对路径：" CertFile
            read -rp "KeyFile绝对路径：" KeyFile
cert_config=$(cat <<EOF
"CertConfig": {
    "CertMode": "self",
    "RejectUnknownSni": false,
    "CertDomain": "$certdomain",
    "CertFile": "$CertFile",
    "KeyFile": "$KeyFile"            
             }
EOF
)
        ;;
		esac
		
		else
		cert_config=""
		fi
	
			# 检查IPV6情况
	if ip -6 addr | grep -q "inet6"; then
        listen_ip="::"  # 支持 IPv6
		echo -e "${green}您的服务器支持IPV6，已自动监听${plain}"
    else
        listen_ip="0.0.0.0"  # 不支持 IPv6
		echo -e "${green}您的服务器不支持IPV6${plain}"
	fi
	
		case "$core_type" in
	1 )
    node_config=$(cat <<EOF
            "Core": "$core",
            "ApiHost": "$ApiHost",
            "ApiKey": "$ApiKey",
            "NodeID": $NodeID,
            "NodeType": "$NodeType",
            "Timeout": 30,
            "ListenIP": "0.0.0.0",
            "SendIP": "0.0.0.0",
            "DeviceOnlineMinTraffic": 100,
            "EnableProxyProtocol": false,
            "EnableUot": true,
            "EnableTFO": true,
            "DNSType": "UseIPv4",
            $cert_config
EOF
)
	;;
	2 )
    node_config=$(cat <<EOF
    "Core": "$core",
    "ApiHost": "$ApiHost",
    "ApiKey": "$ApiKey",
    "NodeID": $NodeID,
    "NodeType": "$NodeType",
    "Timeout": 30,
    "ListenIP": "$listen_ip",
    "SendIP": "0.0.0.0",
    "DeviceOnlineMinTraffic": 100,
    "TCPFastOpen": true,
    "SniffEnabled": true,
    "EnableDNS": true,
    $cert_config
EOF
)
	;;
esac

	# 切换到配置文件目录
    cd /etc/V2bX
    
    # 备份旧的配置文件
    mv config.json config.json.bak

    # 创建 config.json 文件
    cat <<EOF > /etc/V2bX/config.json
{
    "Log": {
        "Level": "error",
        "Output": ""
    },
    "Cores": $core_config,
    "Nodes": [{$node_config}]
}
EOF
    # 创建 custom_outbound.json 文件
    cat <<EOF > /etc/V2bX/custom_outbound.json
    [
        {
            "tag": "IPv4_out",
            "protocol": "freedom",
            "settings": {
                "domainStrategy": "UseIPv4v6"
            }
        },
        {
            "tag": "IPv6_out",
            "protocol": "freedom",
            "settings": {
                "domainStrategy": "UseIPv6"
            }
        },
        {
            "protocol": "blackhole",
            "tag": "block"
        }
    ]
EOF
    
    # 创建 route.json 文件
    cat <<EOF > /etc/V2bX/route.json
    {
        "domainStrategy": "AsIs",
        "rules": [
            {
                "type": "field",
                "outboundTag": "block",
                "ip": [
                    "geoip:private",
                    "geoip:cn"
                ]
            },
            {
                "domain": [
                    "geosite:google"
                ],
                "outboundTag": "IPv4_out",
                "type": "field"
            },
            {
                "type": "field",
                "outboundTag": "block",
                "domain": [
                    "geosite:cn"
                ]
            },
            {
                "type": "field",
                "outboundTag": "block",
                "domain": [
                    "regexp:(api|ps|sv|offnavi|newvector|ulog.imap|newloc)(.map|).(baidu|n.shifen).com",
                    "regexp:(.+.|^)(360|so).(cn|com)",
                    "regexp:(Subject|HELO|SMTP)",
                    "regexp:(torrent|.torrent|peer_id=|info_hash|get_peers|find_node|BitTorrent|announce_peer|announce.php?passkey=)",
                    "regexp:(^.@)(guerrillamail|guerrillamailblock|sharklasers|grr|pokemail|spam4|bccto|chacuo|027168).(info|biz|com|de|net|org|me|la)",
                    "regexp:(.?)(xunlei|sandai|Thunder|XLLiveUD)(.)",
                    "regexp:(..||)(dafahao|mingjinglive|botanwang|minghui|dongtaiwang|falunaz|epochtimes|ntdtv|falundafa|falungong|wujieliulan|zhengjian).(org|com|net)",
                    "regexp:(ed2k|.torrent|peer_id=|announce|info_hash|get_peers|find_node|BitTorrent|announce_peer|announce.php?passkey=|magnet:|xunlei|sandai|Thunder|XLLiveUD|bt_key)",
                    "regexp:(.+.|^)(360).(cn|com|net)",
                    "regexp:(.*.||)(guanjia.qq.com|qqpcmgr|QQPCMGR)",
                    "regexp:(.*.||)(rising|kingsoft|duba|xindubawukong|jinshanduba).(com|net|org)",
                    "regexp:(.*.||)(netvigator|torproject).(com|cn|net|org)",
                    "regexp:(..||)(visa|mycard|gash|beanfun|bank).",
                    "regexp:(.*.||)(gov|12377|12315|talk.news.pts.org|creaders|zhuichaguoji|efcc.org|cyberpolice|aboluowang|tuidang|epochtimes|zhengjian|110.qq|mingjingnews|inmediahk|xinsheng|breakgfw|chengmingmag|jinpianwang|qi-gong|mhradio|edoors|renminbao|soundofhope|xizang-zhiye|bannedbook|ntdtv|12321|secretchina|dajiyuan|boxun|chinadigitaltimes|dwnews|huaglad|oneplusnews|epochweekly|cn.rfi).(cn|com|org|net|club|net|fr|tw|hk|eu|info|me)",
                    "regexp:(.*.||)(miaozhen|cnzz|talkingdata|umeng).(cn|com)",
                    "regexp:(.*.||)(mycard).(com|tw)",
                    "regexp:(.*.||)(gash).(com|tw)",
                    "regexp:(.bank.)",
                    "regexp:(.*.||)(pincong).(rocks)",
                    "regexp:(.*.||)(taobao).(com)",
                    "regexp:(.*.||)(laomoe|jiyou|ssss|lolicp|vv1234|0z|4321q|868123|ksweb|mm126).(com|cloud|fun|cn|gs|xyz|cc)",
                    "regexp:(flows|miaoko).(pages).(dev)"
                ]
            },
            {
                "type": "field",
                "outboundTag": "block",
                "ip": [
                    "127.0.0.1/32",
                    "10.0.0.0/8",
                    "fc00::/7",
                    "fe80::/10",
                    "172.16.0.0/12"
                ]
            },
            {
                "type": "field",
                "outboundTag": "block",
                "protocol": [
                    "bittorrent"
                ]
            }
        ]
    }
EOF

    # 创建 sing_origin.json 文件           
    cat <<EOF > /etc/V2bX/sing_origin.json
{
  "outbounds": [
    {
      "tag": "direct",
      "type": "direct",
      "domain_strategy": "prefer_ipv4"
    },
    {
      "type": "block",
      "tag": "block"
    }
  ],
  "route": {
    "rules": [
      {
        "outbound": "block",
        "geoip": [
          "private"
        ]
      },
      {
        "geosite": [
          "google"
        ],
        "outbound": "direct"
      },
      {
        "geosite": [
          "cn"
        ],
        "outbound": "block"
      },
      {
        "geoip": [
          "cn"
        ],
        "outbound": "block"
      },
      {
        "domain_regex": [
            "(api|ps|sv|offnavi|newvector|ulog.imap|newloc)(.map|).(baidu|n.shifen).com",
            "(.+.|^)(360|so).(cn|com)",
            "(Subject|HELO|SMTP)",
            "(torrent|.torrent|peer_id=|info_hash|get_peers|find_node|BitTorrent|announce_peer|announce.php?passkey=)",
            "(^.@)(guerrillamail|guerrillamailblock|sharklasers|grr|pokemail|spam4|bccto|chacuo|027168).(info|biz|com|de|net|org|me|la)",
            "(.?)(xunlei|sandai|Thunder|XLLiveUD)(.)",
            "(..||)(dafahao|mingjinglive|botanwang|minghui|dongtaiwang|falunaz|epochtimes|ntdtv|falundafa|falungong|wujieliulan|zhengjian).(org|com|net)",
            "(ed2k|.torrent|peer_id=|announce|info_hash|get_peers|find_node|BitTorrent|announce_peer|announce.php?passkey=|magnet:|xunlei|sandai|Thunder|XLLiveUD|bt_key)",
            "(.+.|^)(360).(cn|com|net)",
            "(.*.||)(guanjia.qq.com|qqpcmgr|QQPCMGR)",
            "(.*.||)(rising|kingsoft|duba|xindubawukong|jinshanduba).(com|net|org)",
            "(.*.||)(netvigator|torproject).(com|cn|net|org)",
            "(..||)(visa|mycard|gash|beanfun|bank).",
            "(.*.||)(gov|12377|12315|talk.news.pts.org|creaders|zhuichaguoji|efcc.org|cyberpolice|aboluowang|tuidang|epochtimes|zhengjian|110.qq|mingjingnews|inmediahk|xinsheng|breakgfw|chengmingmag|jinpianwang|qi-gong|mhradio|edoors|renminbao|soundofhope|xizang-zhiye|bannedbook|ntdtv|12321|secretchina|dajiyuan|boxun|chinadigitaltimes|dwnews|huaglad|oneplusnews|epochweekly|cn.rfi).(cn|com|org|net|club|net|fr|tw|hk|eu|info|me)",
            "(.*.||)(miaozhen|cnzz|talkingdata|umeng).(cn|com)",
            "(.*.||)(mycard).(com|tw)",
            "(.*.||)(gash).(com|tw)",
            "(.bank.)",
            "(.*.||)(pincong).(rocks)",
            "(.*.||)(taobao).(com)",
            "(.*.||)(laomoe|jiyou|ssss|lolicp|vv1234|0z|4321q|868123|ksweb|mm126).(com|cloud|fun|cn|gs|xyz|cc)",
            "(flows|miaoko).(pages).(dev)"
        ],
        "outbound": "block"
      },
      {
        "outbound": "direct",
        "network": [
          "udp","tcp"
        ]
      }
    ]
  }
}
EOF
echo -e "${green}V2bX 配置文件生成完成,正在重新启动服务,您原先的配置被被分到config.json.bak${plain}"	
echo -e "${green}再次运行 bash AlpineV2bX.sh${plain}"
rc-service V2bX restart

;;
4)

rc-service V2bX restart

;;
esac
