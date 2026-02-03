#!/bin/bash

CURRENT_PATH=$(pwd)

clone_or_update_git_repo() {
  # 参数检查
  if [ "$#" -lt 2 ]; then
    echo "Usage: clone_or_update_git_repo <git_url> <target_directory> [branch] [subdirectory]"
    return 1
  fi

  local git_url="$1"
  local source_target_directory="$2"
  local target_directory="$2"
  local branch="$3"
  local subdirectory="$4"

  if [ -n "$subdirectory" ]; then
    target_directory=$CURRENT_PATH/repos/$(echo "$git_url" | awk -F'/' '{print $(NF-1)"-"$NF}')
  fi

  # 检查目标目录是否存在
  if [ -d "$target_directory" ]; then
    pushd "$target_directory" || return 1
    git pull
    popd
  else
    if [ -n "$branch" ]; then
      git clone --depth=1 -b "$branch" "$git_url" "$target_directory"
    else
      git clone --depth=1 "$git_url" "$target_directory"
    fi
  fi

  if [ -n "$subdirectory" ]; then
    cp -a $target_directory/$subdirectory $source_target_directory
  fi
}

# theme
git clone --depth=1 -b master https://github.com/jerrykuku/luci-theme-argon package/Wen/luci-theme-argon
# argon-theme-config
git clone --depth=1 -b master https://github.com/jerrykuku/luci-app-argon-config package/Wen/luci-app-argon-config
#mosdns
git clone --depth=1 -b v5 https://github.com/sbwml/luci-app-mosdns package/Wen/luci-app-mosdns
#ssr-plus
#clone_or_update_git_repo https://github.com/fw876/helloworld package/Wen/luci-app-ssr-plus master luci-app-ssr-plus
#passwall
#clone_or_update_git_repo https://github.com/xiaorouji/openwrt-passwall package/Wen/luci-app-passwall luci-smartdns-dev luci-app-passwall
#git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall2 package/Wen/luci-app-passwall2
#git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall-packages package/Wen/luci-app-dependence
#git clone --depth=1 https://github.com/jerrykuku/node-request package/Wen/luci-app-dependence/node-request
#git clone --depth=1 https://github.com/jerrykuku/lua-maxminddb package/Wen/luci-app-dependence/lua-maxminddb
#clone_or_update_git_repo https://github.com/fw876/helloworld package/Wen/luci-app-dependence/lua-neturl master lua-neturl
#clone_or_update_git_repo https://github.com/fw876/helloworld package/Wen/luci-app-dependence/shadow-tls master shadow-tls    
#clone_or_update_git_repo https://github.com/kenzok8/small package/Wen/luci-app-dependence/redsocks2 "" redsocks2
#smartdns
#git clone --depth=1 -b master https://github.com/pymumu/luci-app-smartdns package/Wen/luci-app-smartdns
#git clone --depth=1 https://github.com/pymumu/openwrt-smartdns package/Wen/luci-app-smartdns/smartdns
#openclash
git clone --depth=1 -b dev https://github.com/vernesong/OpenClash package/Wen/luci-app-openclash
#serverchan
git clone --depth=1 -b master https://github.com/tty228/luci-app-wechatpush package/Wen/luci-app-wechatpush
clone_or_update_git_repo https://github.com/kiddin9/kwrt-packages package/Wen/ "" wrtbwmon
#openappfilter
git clone --depth=1 https://github.com/destan19/OpenAppFilter package/Wen/luci-app-oaf
#fileassistant
#clone_or_update_git_repo https://github.com/sirpdboy/sirpdboy-package package/Wen/luci-app-fileassistant "" luci-app-fileassistant
#unblockneteasemusic
git clone --depth=1 -b js https://github.com/UnblockNeteaseMusic/luci-app-unblockneteasemusic package/Wen/luci-app-unblockneteasemusic
#onliner
clone_or_update_git_repo https://github.com/Hyy2001X/AutoBuild-Packages package/Wen/luci-app-onliner "" luci-app-onliner
#alist
#git clone --depth=1 -b lua https://github.com/sbwml/luci-app-alist package/Wen/luci-app-alist
#clone_or_update_git_repo https://github.com/sbwml/luci-app-alist package/Wen/luci-app-alist master alist
#parents-control
#git clone --depth=1 https://github.com/sirpdboy/luci-app-parentcontrol package/Wen/luci-app-parentcontrol
#airconnect
git clone --depth=1 -b main https://github.com/sbwml/luci-app-airconnect package/Wen/luci-app-airconnect
clone_or_update_git_repo https://github.com/sbwml/luci-app-airconnect package/Wen/luci-app-airconnect main airconnect
#homeproxy
#git clone --depth=1 https://github.com/immortalwrt/homeproxy package/Wen/luci-app-homeproxy
#mihomo proxy
#git clone --depth=1 https://github.com/morytyann/OpenWrt-mihomo.git package/Wen/luci-app-mihomo
#subconverter
git clone --depth=1 https://github.com/tindy2013/openwrt-subconverter package/Wen/luci-app-subconverter
#cpu status
git clone --depth=1 https://github.com/gSpotx2f/luci-app-cpu-status package/Wen/luci-app-cpu-status
#tn-netports
git clone --depth=1 https://github.com/muink/luci-app-tn-netports package/Wen/luci-app-tn-netports
#socat
clone_or_update_git_repo https://github.com/Lienol/openwrt-package package/Wen/luci-app-socat main luci-app-socat
#eqosplus
#git clone --depth=1 https://github.com/sirpdboy/luci-app-eqosplus package/Wen/luci-app-eqosplus


