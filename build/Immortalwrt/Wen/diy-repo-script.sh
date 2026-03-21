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
# git clone --depth=1 -b js https://github.com/sirpdboy/luci-theme-kucat package/Wen/luci-theme-kucat
# git clone --depth=1 -b js https://github.com/0x676e67/luci-theme-design package/Wen/luci-theme-design
# argon-theme-config
git clone --depth=1 -b master https://github.com/jerrykuku/luci-app-argon-config package/Wen/luci-app-argon-config
# aurora
git clone --depth=1 https://github.com/eamonxg/luci-theme-aurora package/Wen/luci-theme-aurora
#theme-config
# git clone --depth=1 https://github.com/sirpdboy/luci-app-advancedplus package/Wen/luci-app-advancedplus
#git clone --depth=1 https://github.com/eamonxg/luci-app-aurora-config package/Wen/luci-app-aurora-config
#mosdns
git clone --depth=1 -b v5 https://github.com/sbwml/luci-app-mosdns package/Wen/luci-app-mosdns
#passwall
#clone_or_update_git_repo https://github.com/Openwrt-Passwall/openwrt-passwall package/Wen/luci-app-passwall main luci-app-passwall
git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall2 package/Wen/luci-app-passwall2
#git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall-packages package/Wen/luci-app-dependence
git clone --depth=1 https://github.com/jerrykuku/node-request package/Wen/luci-app-dependence/node-request
#git clone --depth=1 https://github.com/jerrykuku/lua-maxminddb package/Wen/luci-app-dependence/lua-maxminddb
#clone_or_update_git_repo https://github.com/fw876/helloworld package/Wen/luci-app-dependence/lua-neturl master lua-neturl
#clone_or_update_git_repo https://github.com/fw876/helloworld package/Wen/luci-app-dependence/shadow-tls master shadow-tls    
#clone_or_update_git_repo https://github.com/kenzok8/small package/Wen/luci-app-dependence/redsocks2 "" redsocks2
#clone_or_update_git_repo https://github.com/kiddin9/openwrt-packages package/Wen/luci-app-dependence/wrtbwmon "" wrtbwmon

#openclash
git clone --depth=1 -b dev https://github.com/vernesong/OpenClash package/Wen/OpenClash
rm -rf feeds/luci/applications/luci-app-openclash
mv package/Wen/OpenClash/luci-app-openclash feeds/luci/applications/luci-app-openclash

#openappfilter
git clone --depth=1 https://github.com/destan19/OpenAppFilter package/Wen/luci-app-oaf

#timewol
#clone_or_update_git_repo https://github.com/kiddin9/openwrt-packages package/Wen/luci-app-control-timewol "" luci-app-control-timewol
#weburl
#clone_or_update_git_repo https://github.com/kiddin9/openwrt-packages package/Wen/luci-app-control-weburl "" luci-app-control-weburl
#serverchan
git clone --depth=1 -b master https://github.com/tty228/luci-app-wechatpush package/Wen/luci-app-wechatpush
clone_or_update_git_repo https://github.com/kiddin9/op-packages package/Wen/ "" wrtbwmon
#pushbot
#git clone --depth=1 https://github.com/zzsj0928/luci-app-pushbot package/Wen/luci-app-pushbot
#onliner
clone_or_update_git_repo https://github.com/Hyy2001X/AutoBuild-Packages package/Wen/luci-app-onliner "" luci-app-onliner
#airconnect
git clone --depth=1 -b main https://github.com/sbwml/luci-app-airconnect package/Wen/luci-app-airconnect
clone_or_update_git_repo https://github.com/sbwml/luci-app-airconnect package/Wen/luci-app-airconnect main airconnect
#alist
#rm -rf feeds/luci/applications/luci-app-alist
#rm -rf feeds/packages/net/alist
#git clone --depth=1 -b main https://github.com/sbwml/luci-app-alist package/Wen/luci-app-alist
#eqosplus
#git clone --depth=1 https://github.com/sirpdboy/luci-app-eqosplus package/Wen/luci-app-eqosplus
#timecontrol
git clone --depth=1 -b main https://github.com/sirpdboy/luci-app-timecontrol package/Wen/luci-app-timecontrol
#taskplan
#git clone --depth=1 https://github.com/sirpdboy/luci-app-taskplan package/Wen/luci-app-taskplan
#subconverter
#git clone --depth=1 https://github.com/kiddin9/openwrt-subconverter package/Wen/luci-app-subconverter
#cpu status
#git clone --depth=1 https://github.com/gSpotx2f/luci-app-cpu-status package/Wen/luci-app-cpu-status
#tn-netports
#git clone --depth=1 https://github.com/muink/luci-app-tn-netports package/Wen/luci-app-tn-netports
#internet-detector
git clone --depth=1 https://github.com/GWen124/luci-app-internet-detector package/Wen/luci-app-internet-detector
#tailscale
git clone --depth=1 https://github.com/asvow/luci-app-tailscale package/Wen/luci-app-tailscale
#lucky
#git clone --depth=1 https://github.com/sirpdboy/luci-app-lucky package/Wen/luci-app-lucky
#yt-dlp
#git clone --depth=1 https://github.com/liudf0716/luci-app-yt-dlp package/Wen/luci-app-yt-dlp
#Nikki
#git clone --depth=1 https://github.com/nikkinikki-org/OpenWrt-nikki package/Wen/luci-app-nikki
#socat
# clone_or_update_git_repo https://github.com/Lienol/openwrt-package package/Wen/luci-app-socat "" luci-app-socat
#insomclash
#git clone --depth=1 https://github.com/bobbyunknown/luci-app-insomclash package/Wen/luci-app-insomclash
#bandix
#git clone --depth=1 https://github.com/timsaya/luci-app-bandix package/Wen/luci-app-bandix
#git clone --depth=1 https://github.com/timsaya/openwrt-bandix package/Wen/openwrt-bandix
#rm -f "package/Wen/openwrt-bandix/.github/workflows/Auto compile with openwrt sdk.yml"