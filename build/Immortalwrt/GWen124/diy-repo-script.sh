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
# git clone --depth=1 -b js https://github.com/sirpdboy/luci-theme-kucat package/GWen124/luci-theme-kucat
# git clone --depth=1 -b js https://github.com/0x676e67/luci-theme-design package/GWen124/luci-theme-design
# argon-theme-config
git clone --depth=1 -b master https://github.com/jerrykuku/luci-app-argon-config package/GWen124/luci-app-argon-config
#theme-config
# git clone --depth=1 https://github.com/sirpdboy/luci-app-advancedplus package/GWen124/luci-app-advancedplus
#mosdns
git clone --depth=1 -b v5 https://github.com/sbwml/luci-app-mosdns package/GWen124/luci-app-mosdns
#passwall
#clone_or_update_git_repo https://github.com/Openwrt-Passwall/openwrt-passwall package/GWen124/luci-app-passwall main luci-app-passwall
git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall2 package/GWen124/luci-app-passwall2
#git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall-packages package/GWen124/luci-app-dependence
git clone --depth=1 https://github.com/jerrykuku/node-request package/GWen124/luci-app-dependence/node-request
#git clone --depth=1 https://github.com/jerrykuku/lua-maxminddb package/GWen124/luci-app-dependence/lua-maxminddb
#clone_or_update_git_repo https://github.com/fw876/helloworld package/GWen124/luci-app-dependence/lua-neturl master lua-neturl
#clone_or_update_git_repo https://github.com/fw876/helloworld package/GWen124/luci-app-dependence/shadow-tls master shadow-tls    
#clone_or_update_git_repo https://github.com/kenzok8/small package/GWen124/luci-app-dependence/redsocks2 "" redsocks2
#clone_or_update_git_repo https://github.com/kiddin9/openwrt-packages package/GWen124/luci-app-dependence/wrtbwmon "" wrtbwmon

#openclash
git clone --depth=1 -b dev https://github.com/vernesong/OpenClash package/GWen124/OpenClash
rm -rf feeds/luci/applications/luci-app-openclash
mv package/GWen124/OpenClash/luci-app-openclash feeds/luci/applications/luci-app-openclash

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
#alist
#rm -rf feeds/luci/applications/luci-app-alist
#rm -rf feeds/packages/net/alist
#git clone --depth=1 -b main https://github.com/sbwml/luci-app-alist package/GWen124/luci-app-alist
#eqosplus
#git clone --depth=1 https://github.com/sirpdboy/luci-app-eqosplus package/GWen124/luci-app-eqosplus
#timecontrol
git clone --depth=1 -b main https://github.com/sirpdboy/luci-app-timecontrol package/GWen124/luci-app-timecontrol
#taskplan
#git clone --depth=1 https://github.com/sirpdboy/luci-app-taskplan package/GWen124/luci-app-taskplan
#subconverter
git clone --depth=1 https://github.com/kiddin9/openwrt-subconverter package/GWen124/luci-app-subconverter
#cpu status
#git clone --depth=1 https://github.com/gSpotx2f/luci-app-cpu-status package/GWen124/luci-app-cpu-status
#tn-netports
#git clone --depth=1 https://github.com/muink/luci-app-tn-netports package/GWen124/luci-app-tn-netports
#tailscale
git clone --depth=1 https://github.com/asvow/luci-app-tailscale package/GWen124/luci-app-tailscale
#lucky
#git clone --depth=1 https://github.com/sirpdboy/luci-app-lucky package/GWen124/luci-app-lucky
#yt-dlp
git clone --depth=1 https://github.com/liudf0716/luci-app-yt-dlp package/GWen124/luci-app-yt-dlp
#Nikki
#git clone --depth=1 https://github.com/nikkinikki-org/OpenWrt-nikki package/GWen124/luci-app-nikki
#socat
# clone_or_update_git_repo https://github.com/Lienol/openwrt-package package/GWen124/luci-app-socat "" luci-app-socat
#insomclash
#git clone --depth=1 https://github.com/bobbyunknown/luci-app-insomclash package/GWen124/luci-app-insomclash
#bandix
git clone --depth=1 https://github.com/timsaya/luci-app-bandix package/GWen124/luci-app-bandix
git clone --depth=1 https://github.com/timsaya/openwrt-bandix package/GWen124/openwrt-bandix
rm -f "package/GWen124/openwrt-bandix/.github/workflows/Auto compile with openwrt sdk.yml"
