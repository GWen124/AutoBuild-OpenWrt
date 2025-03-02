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
git clone --depth=1 -b master https://github.com/jerrykuku/luci-theme-argon package/GWen124/luci-theme-argon
# argon-theme-config
git clone --depth=1 -b master https://github.com/jerrykuku/luci-app-argon-config package/GWen124/luci-app-argon-config
#mosdns
git clone --depth=1 -b v5 https://github.com/sbwml/luci-app-mosdns package/GWen124/luci-app-mosdns
#passwall
#clone_or_update_git_repo https://github.com/xiaorouji/openwrt-passwall package/GWen124/luci-app-passwall main luci-app-passwall
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall2 package/GWen124/luci-app-passwall2
#git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall-packages package/GWen124/luci-app-dependence
git clone --depth=1 https://github.com/jerrykuku/node-request package/GWen124/luci-app-dependence/node-request
#git clone --depth=1 https://github.com/jerrykuku/lua-maxminddb package/GWen124/luci-app-dependence/lua-maxminddb
#clone_or_update_git_repo https://github.com/fw876/helloworld package/GWen124/luci-app-dependence/lua-neturl master lua-neturl
#clone_or_update_git_repo https://github.com/fw876/helloworld package/GWen124/luci-app-dependence/shadow-tls master shadow-tls    
#clone_or_update_git_repo https://github.com/kenzok8/small package/GWen124/luci-app-dependence/redsocks2 "" redsocks2
#clone_or_update_git_repo https://github.com/kiddin9/openwrt-packages package/GWen124/luci-app-dependence/wrtbwmon "" wrtbwmon

#openclash
git clone --depth=1 -b dev https://github.com/vernesong/OpenClash package/GWen124/luci-app-openclash

#openappfilter
git clone --depth=1 https://github.com/destan19/OpenAppFilter package/GWen124/luci-app-oaf

#timewol
#clone_or_update_git_repo https://github.com/kiddin9/openwrt-packages package/GWen124/luci-app-control-timewol "" luci-app-control-timewol
#weburl
#clone_or_update_git_repo https://github.com/kiddin9/openwrt-packages package/GWen124/luci-app-control-weburl "" luci-app-control-weburl
#serverchan
git clone --depth=1 -b master https://github.com/tty228/luci-app-wechatpush package/GWen124/luci-app-wechatpush
clone_or_update_git_repo https://github.com/kiddin9/kwrt-packages package/GWen124/ "" wrtbwmon
#pushbot
#git clone --depth=1 https://github.com/zzsj0928/luci-app-pushbot package/GWen124/luci-app-pushbot
#onliner
clone_or_update_git_repo https://github.com/Hyy2001X/AutoBuild-Packages package/GWen124/luci-app-onliner "" luci-app-onliner
#airconnect
git clone --depth=1 -b main https://github.com/sbwml/luci-app-airconnect package/GWen124/luci-app-airconnect
clone_or_update_git_repo https://github.com/sbwml/luci-app-airconnect package/GWen124/luci-app-airconnect main airconnect
#eqosplus
git clone --depth=1 https://github.com/sirpdboy/luci-app-eqosplus package/GWen124/luci-app-eqosplus
#subconverter
git clone --depth=1 https://github.com/tindy2013/openwrt-subconverter package/GWen124/subconverter
#git clone --depth=1 https://github.com/0x2196f3/luci-app-subconverter package/GWen124/luci-app-subconverter
#mihomo proxy
git clone --depth=1 https://github.com/nikkinikki-org/OpenWrt-nikki package/GWen124/luci-app-nikki
#cpu status
git clone --depth=1 https://github.com/gSpotx2f/luci-app-cpu-status package/GWen124/luci-app-cpu-status
#tn-netports
git clone --depth=1 https://github.com/muink/luci-app-tn-netports package/GWen124/luci-app-tn-netports
#lucky
#git clone --depth=1 https://github.com/sirpdboy/luci-app-lucky package/GWen124/luci-app-lucky
#yt-dlp
git clone --depth=1 https://github.com/liudf0716/luci-app-yt-dlp package/GWen124/luci-app-yt-dlp
