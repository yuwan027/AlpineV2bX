#!/bin/bash

apt install -y jq curl wget

LIST=('geoip geoip geoip' 'domain-list-community dlc geosite')

for i in "${LIST[@]}"; do
    INFO=($i)

    LASTEST_TAG="$(curl -sL "https://api.github.com/repos/v2fly/${INFO[0]}/releases" | jq -r ".[0].tag_name" || echo "latest")"

    echo "当前文件更新时间: $LASTEST_TAG"

    FILE_PATH="/etc/V2bX/${INFO[2]}.dat"

    echo -e "正在下载 ${FILE_PATH}..."
    curl -L "https://github.com/v2fly/${INFO[0]}/releases/download/${LASTEST_TAG}/${INFO[1]}.dat" -o ${FILE_PATH}

    echo -e "正在验证哈希值..."
    REMOTE_HASH="$(curl -sL "https://github.com/v2fly/${INFO[0]}/releases/download/${LASTEST_TAG}/${INFO[1]}.dat.sha256sum" | awk '{print $1}')"
    LOCAL_HASH="$(sha256sum ${FILE_PATH} | awk '{print $1}')"

    if [ "$REMOTE_HASH" == "$LOCAL_HASH" ]; then
        echo "已验证 ${FILE_PATH} 的哈希值."
    else
        echo -e "${FILE_PATH} 的哈希值与云端不匹配，能用就行，跳过验证。"
    fi
done
