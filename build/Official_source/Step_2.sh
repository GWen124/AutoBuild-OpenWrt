#!/bin/bash
clear

### 基础部分 ###
# 使用 O2 级别的优化
sed -i 's/Os/O2/g' include/target.mk
# 更新 Feeds
./scripts/feeds update -a
./scripts/feeds install -a
# 默认开启 Irqbalance
sed -i "s/enabled '0'/enabled '1'/g" feeds/packages/utils/irqbalance/files/irqbalance.config
# 移除 SNAPSHOT 标签
sed -i 's,-SNAPSHOT,,g' include/version.mk
sed -i 's,-SNAPSHOT,,g' package/base-files/image-config.in
# 维多利亚的秘密
rm -rf ./scripts/download.pl
rm -rf ./include/download.mk
cp -rf ../immortalwrt/scripts/download.pl ./scripts/download.pl
cp -rf ../immortalwrt/include/download.mk ./include/download.mk
sed -i '/unshift/d' scripts/download.pl
sed -i '/mirror02/d' scripts/download.pl
echo "net.netfilter.nf_conntrack_helper = 1" >>./package/kernel/linux/files/sysctl-nf-conntrack.conf
# Nginx
sed -i "s/client_max_body_size 128M/client_max_body_size 2048M/g" feeds/packages/net/nginx-util/files/uci.conf.template
sed -i '/client_max_body_size/a\\tclient_body_buffer_size 8192M;' feeds/packages/net/nginx-util/files/uci.conf.template
sed -i '/ubus_parallel_req/a\        ubus_script_timeout 600;' feeds/packages/net/nginx/files-luci-support/60_nginx-luci-support
sed -ri "/luci-webui.socket/i\ \t\tuwsgi_send_timeout 600\;\n\t\tuwsgi_connect_timeout 600\;\n\t\tuwsgi_read_timeout 600\;" feeds/packages/net/nginx/files-luci-support/luci.locations
sed -ri "/luci-cgi_io.socket/i\ \t\tuwsgi_send_timeout 600\;\n\t\tuwsgi_connect_timeout 600\;\n\t\tuwsgi_read_timeout 600\;" feeds/packages/net/nginx/files-luci-support/luci.locations

### 必要的 Patches ###
# introduce "MG-LRU" Linux kernel patches
cp -rf ../PATCH/backport/MG-LRU/* ./target/linux/generic/pending-5.10/
# TCP optimizations
cp -rf ../PATCH/backport/TCP/* ./target/linux/generic/backport-5.10/
# Patch arm64 型号名称
cp -rf ../immortalwrt/target/linux/generic/hack-5.10/312-arm64-cpuinfo-Add-model-name-in-proc-cpuinfo-for-64bit-ta.patch ./target/linux/generic/hack-5.10/312-arm64-cpuinfo-Add-model-name-in-proc-cpuinfo-for-64bit-ta.patch
# BBRv2
cp -rf ../PATCH/BBRv2/kernel/* ./target/linux/generic/hack-5.10/
cp -rf ../PATCH/BBRv2/openwrt/package ./
wget -qO - https://github.com/openwrt/openwrt/commit/7db9763.patch | patch -p1
# LRNG
cp -rf ../PATCH/LRNG/* ./target/linux/generic/hack-5.10/
# SSL
rm -rf ./package/libs/mbedtls
cp -rf ../immortalwrt/package/libs/mbedtls ./package/libs/mbedtls
rm -rf ./package/libs/openssl
cp -rf ../immortalwrt_21/package/libs/openssl ./package/libs/openssl
# fstool
wget -qO - https://github.com/coolsnowwolf/lede/commit/8a4db76.patch | patch -p1

### Fullcone-NAT 部分 ###
# Patch Kernel 以解决 FullCone 冲突
cp -rf ../lede/target/linux/generic/hack-5.10/952-net-conntrack-events-support-multiple-registrant.patch ./target/linux/generic/hack-5.10/952-net-conntrack-events-support-multiple-registrant.patch
cp -rf ../lede/target/linux/generic/hack-5.10/982-add-bcm-fullconenat-support.patch ./target/linux/generic/hack-5.10/982-add-bcm-fullconenat-support.patch
# Patch FireWall 以增添 FullCone 功能
# FW4
rm -rf ./package/network/config/firewall4
cp -rf ../immortalwrt/package/network/config/firewall4 ./package/network/config/firewall4
cp -f ../PATCH/firewall/990-unconditionally-allow-ct-status-dnat.patch ./package/network/config/firewall4/patches/990-unconditionally-allow-ct-status-dnat.patch
rm -rf ./package/libs/libnftnl
cp -rf ../immortalwrt/package/libs/libnftnl ./package/libs/libnftnl
rm -rf ./package/network/utils/nftables
cp -rf ../immortalwrt/package/network/utils/nftables ./package/network/utils/nftables
# FW3
mkdir -p package/network/config/firewall/patches
cp -rf ../immortalwrt_21/package/network/config/firewall/patches/100-fullconenat.patch ./package/network/config/firewall/patches/100-fullconenat.patch
cp -rf ../lede/package/network/config/firewall/patches/101-bcm-fullconenat.patch ./package/network/config/firewall/patches/101-bcm-fullconenat.patch
# iptables
cp -rf ../lede/package/network/utils/iptables/patches/900-bcm-fullconenat.patch ./package/network/utils/iptables/patches/900-bcm-fullconenat.patch
# network
wget -qO - https://github.com/openwrt/openwrt/commit/bbf39d07.patch | patch -p1
# Patch LuCI 以增添 FullCone 开关
pushd feeds/luci
wget -qO- https://github.com/openwrt/luci/commit/471182b2.patch | patch -p1
popd
# FullCone PKG
git clone --depth 1 https://github.com/fullcone-nat-nftables/nft-fullcone package/waynesg/nft-fullcone
cp -rf ../Lienol/package/network/utils/fullconenat ./package/waynesg/fullconenat

### 获取额外的基础软件包 ###
# 更换为 ImmortalWrt Uboot 以及 Target
rm -rf ./target/linux/rockchip
cp -rf ../lede/target/linux/rockchip ./target/linux/rockchip
rm -rf ./target/linux/rockchip/Makefile
cp -rf ../openwrt_release/target/linux/rockchip/Makefile ./target/linux/rockchip/Makefile
rm -rf ./target/linux/rockchip/armv8/config-5.10
cp -rf ../openwrt_release/target/linux/rockchip/armv8/config-5.10 ./target/linux/rockchip/armv8/config-5.10
rm -rf ./target/linux/rockchip/patches-5.10/002-net-usb-r8152-add-LED-configuration-from-OF.patch
rm -rf ./target/linux/rockchip/patches-5.10/003-dt-bindings-net-add-RTL8152-binding-documentation.patch
cp -rf ../PATCH/rockchip-5.10/* ./target/linux/rockchip/patches-5.10/
rm -rf ./package/firmware/linux-firmware/intel.mk
cp -rf ../lede/package/firmware/linux-firmware/intel.mk ./package/firmware/linux-firmware/intel.mk
rm -rf ./package/firmware/linux-firmware/Makefile
cp -rf ../lede/package/firmware/linux-firmware/Makefile ./package/firmware/linux-firmware/Makefile
mkdir -p target/linux/rockchip/files-5.10
cp -rf ../PATCH/files-5.10 ./target/linux/rockchip/
sed -i 's,+LINUX_6_1:kmod-drm-display-helper,,g' target/linux/rockchip/modules.mk
sed -i '/drm_dp_aux_bus\.ko/d' target/linux/rockchip/modules.mk
rm -rf ./package/boot/uboot-rockchip
cp -rf ../lede/package/boot/uboot-rockchip ./package/boot/uboot-rockchip
cp -rf ../lede/package/boot/arm-trusted-firmware-rockchip-vendor ./package/boot/arm-trusted-firmware-rockchip-vendor
rm -rf ./package/kernel/linux/modules/video.mk
cp -rf ../immortalwrt/package/kernel/linux/modules/video.mk ./package/kernel/linux/modules/video.mk
sed -i '/nouveau\.ko/d' package/kernel/linux/modules/video.mk
# Disable Mitigations
sed -i 's,rootwait,rootwait mitigations=off,g' target/linux/rockchip/image/mmc.bootscript
sed -i 's,rootwait,rootwait mitigations=off,g' target/linux/rockchip/image/nanopi-r2s.bootscript
sed -i 's,rootwait,rootwait mitigations=off,g' target/linux/rockchip/image/nanopi-r4s.bootscript
sed -i 's,noinitrd,noinitrd mitigations=off,g' target/linux/x86/image/grub-efi.cfg
sed -i 's,noinitrd,noinitrd mitigations=off,g' target/linux/x86/image/grub-iso.cfg
sed -i 's,noinitrd,noinitrd mitigations=off,g' target/linux/x86/image/grub-pc.cfg
# Dnsmasq
rm -rf ./package/network/services/dnsmasq
cp -rf ../openwrt_ma/package/network/services/dnsmasq ./package/network/services/dnsmasq
cp -rf ../openwrt_luci_ma/modules/luci-mod-network/htdocs/luci-static/resources/view/network/dhcp.js ./feeds/luci/modules/luci-mod-network/htdocs/luci-static/resources/view/network/


### 获取额外的 LuCI 应用、主题和依赖 ###
# dae ready
cp -rf ../immortalwrt/config/Config-kernel.in ./config/Config-kernel.in
rm -rf ./tools/dwarves
cp -rf ../openwrt_ma/tools/dwarves ./tools/dwarves
wget -qO - https://github.com/openwrt/openwrt/commit/aa95787e.patch | patch -p1
wget -qO - https://github.com/openwrt/openwrt/commit/29d7d6a8.patch | patch -p1
rm -rf ./tools/elfutils
cp -rf ../openwrt_ma/tools/elfutils ./tools/elfutils
rm -rf ./package/libs/elfutils
cp -rf ../openwrt_ma/package/libs/elfutils ./package/libs/elfutils
wget -qO - https://github.com/openwrt/openwrt/commit/b839f3d5.patch | patch -p1
rm -rf ./feeds/packages/net/frr
cp -rf ../openwrt_pkg_ma/net/frr feeds/packages/net/frr
cp -rf ../immortalwrt_pkg/net/dae ./feeds/packages/net/dae
ln -sf ../../../feeds/packages/net/dae ./package/feeds/packages/dae
# i915
wget -qO - https://github.com/openwrt/openwrt/commit/c21a3570.patch | patch -p1
cp -rf ../lede/target/linux/x86/64/config-5.10 ./target/linux/x86/64/config-5.10
# Haproxy
rm -rf ./feeds/packages/net/haproxy
cp -rf ../openwrt_pkg_ma/net/haproxy feeds/packages/net/haproxy
pushd feeds/packages
wget -qO - https://github.com/openwrt/packages/commit/a09cbcd.patch | patch -p1
popd
# AutoCore
cp -rf ../waynesg_pkg/openwrt-diy/autocore ./package/waynesg/autocore
sed -i 's/"getTempInfo" /"getTempInfo", "getCPUBench", "getCPUUsage" /g' package/waynesg/autocore/files/generic/luci-mod-status-autocore.json
sed -i '/"$threads"/d' package/waynesg/autocore/files/x86/autocore
rm -rf ./feeds/packages/utils/coremark
cp -rf ../immortalwrt_pkg/utils/coremark ./feeds/packages/utils/coremark
# Airconnect
cp -rf ../waynesg_pkg/luci-app-airconnect/airconnect ./package/waynesg/airconnect
cp -rf ../waynesg_pkg/luci-app-airconnect ./package/waynesg/luci-app-airconnect
sed -i 's/"AirConnect"/"音频串流"/g' ./package/waynesg/luci-app-airconnect/luasrc/controller/airconnect.lua
# luci-app-irqbalance
cp -rf ../waynesg_pkg/luci-app-irqbalance ./package/waynesg/luci-app-irqbalance
sed -i 's/"中断均衡器"/"中断均衡"/g' ./package/waynesg/luci-app-irqbalance/po/zh-cn/luci-app-irqbalance.po
# AutoUpdate
git clone https://github.com/waynesg/luci-app-autoupdate package/waynesg/luci-app-autoupdate
# 更换 Nodejs 版本
#rm -rf ./feeds/packages/lang/node
#cp -rf ../openwrt-node/node ./feeds/packages/lang/node
#rm -rf ./feeds/packages/lang/node-arduino-firmata
#cp -rf ../openwrt-node/node-arduino-firmata ./feeds/packages/lang/node-arduino-firmata
#rm -rf ./feeds/packages/lang/node-cylon
#cp -rf ../openwrt-node/node-cylon ./feeds/packages/lang/node-cylon
#rm -rf ./feeds/packages/lang/node-hid
#cp -rf ../openwrt-node/node-hid ./feeds/packages/lang/node-hid
#rm -rf ./feeds/packages/lang/node-homebridge
#cp -rf ../openwrt-node/node-homebridge ./feeds/packages/lang/node-homebridge
#rm -rf ./feeds/packages/lang/node-serialport
#cp -rf ../openwrt-node/node-serialport ./feeds/packages/lang/node-serialport
#rm -rf ./feeds/packages/lang/node-serialport-bindings
#cp -rf ../openwrt-node/node-serialport-bindings ./feeds/packages/lang/node-serialport-bindings
#rm -rf ./feeds/packages/lang/node-yarn
#cp -rf ../openwrt-node/node-yarn ./feeds/packages/lang/node-yarn
#ln -sf ../../../feeds/packages/lang/node-yarn ./package/feeds/packages/node-yarn
#cp -rf ../openwrt-node/node-serialport-bindings-cpp ./feeds/packages/lang/node-serialport-bindings-cpp
#ln -sf ../../../feeds/packages/lang/node-serialport-bindings-cpp ./package/feeds/packages/node-serialport-bindings-cpp
# R8168驱动
git clone -b master --depth 1 https://github.com/BROBIRD/openwrt-r8168.git package/waynesg/r8168
patch -p1 <../PATCH/r8168/r8168-fix_LAN_led-for_r4s-from_TL.patch
# R8152驱动
cp -rf ../immortalwrt/package/kernel/r8152 ./package/waynesg/r8152
# r8125驱动
git clone https://github.com/sbwml/package_kernel_r8125 package/waynesg/r8125
# igc-backport
cp -rf ../PATCH/igc-files-5.10 ./target/linux/x86/files-5.10
# UPX 可执行软件压缩
sed -i '/patchelf pkgconf/i\tools-y += ucl upx' ./tools/Makefile
sed -i '\/autoconf\/compile :=/i\$(curdir)/upx/compile := $(curdir)/ucl/compile' ./tools/Makefile
cp -rf ../Lienol/tools/ucl ./tools/ucl
cp -rf ../Lienol/tools/upx ./tools/upx
# 更换 golang 版本
rm -rf ./feeds/packages/lang/golang
cp -rf ../openwrt_pkg_ma/lang/golang ./feeds/packages/lang/golang
# 访问控制
cp -rf ../lede_luci/applications/luci-app-accesscontrol ./package/waynesg/luci-app-accesscontrol
sed -i 's/"上网时间控制"/"时间控制"/g' ./package/waynesg/luci-app-accesscontrol/po/zh-cn/mia.po
cp -rf ../waynesg_pkg/luci-app-control-weburl ./package/waynesg/luci-app-control-weburl
cp -rf ../waynesg_pkg/luci-app-control-speedlimit ./package/waynesg/luci-app-control-speedlimit
cp -rf ../waynesg_pkg/luci-app-control-timewol ./package/waynesg/luci-app-control-timewol
cp -rf ../waynesg_pkg/luci-app-control-webrestriction ./package/waynesg/luci-app-control-webrestriction
cp -rf ../waynesg_pkg/luci-app-parentcontrol ./package/waynesg/luci-app-parentcontrol
# Argon 主题
git clone -b master --depth 1 https://github.com/jerrykuku/luci-theme-argon.git package/waynesg/luci-theme-argon
rm -rf ./package/waynesg/luci-theme-argon/htdocs/luci-static/argon/background/README.md
git clone -b master --depth 1 https://github.com/jerrykuku/luci-app-argon-config.git package/waynesg/luci-app-argon-config
sed -i 's/"Argon 主题设置"/"主题设置"/g' ./package/waynesg/luci-app-argon-config/luasrc/controller/argon-config.lua
# MAC 地址与 IP 绑定
cp -rf ../immortalwrt_luci/applications/luci-app-arpbind ./feeds/luci/applications/luci-app-arpbind
sed -i 's/"IP\/MAC 绑定"/"地址绑定"/g' ./feeds/luci/applications/luci-app-arpbind/po/zh_Hans/arpbind.po
ln -sf ../../../feeds/luci/applications/luci-app-arpbind ./package/feeds/luci/luci-app-arpbind
# Boost 通用即插即用
rm -rf ./feeds/packages/net/miniupnpd
cp -rf ../openwrt_pkg_ma/net/miniupnpd ./feeds/packages/net/miniupnpd
pushd feeds/packages
wget -qO- https://github.com/openwrt/packages/commit/785bbcb.patch | patch -p1
wget -qO- https://github.com/openwrt/packages/commit/d811cb4.patch | patch -p1
wget -qO- https://github.com/openwrt/packages/commit/9a2da85.patch | patch -p1
wget -qO- https://github.com/openwrt/packages/commit/71dc090.patch | patch -p1
popd
wget -P feeds/packages/net/miniupnpd/patches/ https://github.com/ptpt52/openwrt-packages/raw/master/net/miniupnpd/patches/201-change-default-chain-rule-to-accept.patch
wget -P feeds/packages/net/miniupnpd/patches/ https://github.com/ptpt52/openwrt-packages/raw/master/net/miniupnpd/patches/500-0004-miniupnpd-format-xml-to-make-some-app-happy.patch
wget -P feeds/packages/net/miniupnpd/patches/ https://github.com/ptpt52/openwrt-packages/raw/master/net/miniupnpd/patches/500-0005-miniupnpd-stun-ignore-external-port-changed.patch
wget -P feeds/packages/net/miniupnpd/patches/ https://github.com/ptpt52/openwrt-packages/raw/master/net/miniupnpd/patches/500-0006-miniupnpd-fix-stun-POSTROUTING-filter-for-openwrt.patch
rm -rf ./feeds/luci/applications/luci-app-upnp
cp -rf ../openwrt_luci_ma/applications/luci-app-upnp ./feeds/luci/applications/luci-app-upnp
sed -i 's/msgstr "UPnP"/msgstr "UPnP服务"/g' ./feeds/luci/applications/luci-app-upnp/po/zh_Hans/upnp.po
pushd feeds/luci
wget -qO- https://github.com/openwrt/luci/commit/0b5fb915.patch | patch -p1
popd
# CPU 控制相关
cp -rf ../immortalwrt_luci/applications/luci-app-cpufreq ./feeds/luci/applications/luci-app-cpufreq
sed -i 's/"CPU 性能优化调节"/"CPU优化"/g' ./feeds/luci/applications/luci-app-cpufreq/po/zh_Hans/cpufreq.po
ln -sf ../../../feeds/luci/applications/luci-app-cpufreq ./package/feeds/luci/luci-app-cpufreq
sed -i 's,1608,1800,g' feeds/luci/applications/luci-app-cpufreq/root/etc/uci-defaults/10-cpufreq
sed -i 's,2016,2208,g' feeds/luci/applications/luci-app-cpufreq/root/etc/uci-defaults/10-cpufreq
sed -i 's,1512,1608,g' feeds/luci/applications/luci-app-cpufreq/root/etc/uci-defaults/10-cpufreq
rm -rf ./feeds/luci/applications/luci-app-cpulimit
rm -rf ./feeds/packages/utils/miniupnpd
cp -rf ../immortalwrt_luci/applications/luci-app-cpulimit ./package/waynesg/luci-app-cpulimit
sed -i 's/"CPU占用率限制"/"CPU限制"/g' ./package/waynesg/luci-app-cpulimit/po/zh_Hans/cpulimit.po
cp -rf ../immortalwrt_pkg/utils/cpulimit ./feeds/packages/utils/cpulimit
ln -sf ../../../feeds/packages/utils/cpulimit ./package/feeds/packages/cpulimit
# 动态DNS
rm -rf ./feeds/luci/applications/luci-app-ddns
svn co https://github.com/kiddin9/openwrt-packages/trunk/luci-app-ddns package/waynesg/luci-app-ddns
sed -i 's/+ddns-scripts-aliyun/+ddns-scripts_aliyun/g' ./package/waynesg/luci-app-ddns/Makefile
sed -i 's/+ddns-scripts-dnspod/+ddns-scripts_dnspod/g' ./package/waynesg/luci-app-ddns/Makefile
sed -i 's/+ddns-scripts-cloudflare//g' ./package/waynesg/luci-app-ddns/Makefile
sed -i '/boot()/,+2d' feeds/packages/net/ddns-scripts/files/etc/init.d/ddns
cp -rf ../openwrt-third/ddns-scripts_aliyun ./feeds/packages/net/ddns-scripts_aliyun
ln -sf ../../../feeds/packages/net/ddns-scripts_aliyun ./package/feeds/packages/ddns-scripts_aliyun
cp -rf ../openwrt-third/ddns-scripts_dnspod ./feeds/packages/net/ddns-scripts_dnspod
ln -sf ../../../feeds/packages/net/ddns-scripts_dnspod ./package/feeds/packages/ddns-scripts_dnspod
# Docker 容器
rm -rf ./feeds/luci/applications/luci-app-dockerman
cp -rf ../dockerman/applications/luci-app-dockerman ./feeds/luci/applications/luci-app-dockerman
#sed -i 's/"Docker"/"Docker容器"/g' ./feeds/luci/applications/luci-app-dockerman/po/zh-cn/dockerman.po
sed -i '/auto_start/d' feeds/luci/applications/luci-app-dockerman/root/etc/uci-defaults/luci-app-dockerman
pushd feeds/luci
wget -qO- https://github.com/openwrt/luci/commit/0c1fc7f.patch | patch -p1
popd
pushd feeds/packages
wget -qO- https://github.com/openwrt/packages/commit/d9d5109.patch | patch -p1
popd
sed -i '/sysctl.d/d' feeds/packages/utils/dockerd/Makefile
rm -rf ./feeds/luci/collections/luci-lib-docker
cp -rf ../docker_lib/collections/luci-lib-docker ./feeds/luci/collections/luci-lib-docker
# DiskMan
cp -rf ../diskman/applications/luci-app-diskman ./package/waynesg/luci-app-diskman
mkdir -p package/waynesg/parted && \
wget https://raw.githubusercontent.com/lisaac/luci-app-diskman/master/Parted.Makefile -O package/waynesg/parted/Makefile
# IPSec
cp -rf ../lede_luci/applications/luci-app-ipsec-server ./package/waynesg/luci-app-ipsec-server
# OVPN
cp -rf ../openwrt_luci_ma/applications/luci-app-openvpn ./package/waynesg/luci-app-openvpn
cp -rf ../waynesg_pkg/luci-app-openvpn-server ./package/waynesg/luci-app-openvpn-server
# IPv6 兼容助手
cp -rf ../lede/package/lean/ipv6-helper ./package/waynesg/ipv6-helper
# Mosdns
cp -rf ../mosdns/mosdns ./package/waynesg/mosdns
cp -rf ../mosdns/luci-app-mosdns ./package/waynesg/luci-app-mosdns
cp -rf ../mosdns/v2dat ./package/waynesg/v2dat
sed -i 's/"PKG_BUILD_DEPENDS:=golang\/host"/"PKG_BUILD_DEPENDS:=golang\/host upx\/host"/g' package/waynesg/mosdns/Makefile
# 流量监管
cp -rf ../lede_luci/applications/luci-app-netdata ./package/waynesg/luci-app-netdata
# 上网 APP 过滤
git clone -b master --depth 1 https://github.com/destan19/OpenAppFilter.git package/waynesg/OpenAppFilter
pushd package/waynesg/OpenAppFilter
wget -qO - https://github.com/QiuSimons/OpenAppFilter-destan19/commit/9088cc2.patch | patch -p1
wget https://destan19.github.io/assets/oaf/open_feature/feature-cn-22-06-21.cfg -O ./open-app-filter/files/feature.cfg
popd
# Passwall
cp -rf ../passwall_luci/luci-app-passwall ./package/waynesg/luci-app-passwall
pushd package/waynesg/luci-app-passwall
sed -i 's,iptables-legacy,iptables-nft,g' Makefile
popd
cp -rf ../passwall_pkg/tcping ./package/waynesg/tcping
cp -rf ../passwall_pkg/chinadns-ng ./package/waynesg/chinadns-ng
cp -rf ../passwall_pkg/trojan-go ./package/waynesg/trojan-go
cp -rf ../passwall_pkg/brook ./package/waynesg/brook
cp -rf ../passwall_pkg/ssocks ./package/waynesg/ssocks
cp -rf ../passwall_pkg/microsocks ./package/waynesg/microsocks
cp -rf ../passwall_pkg/dns2socks ./package/waynesg/dns2socks
cp -rf ../passwall_pkg/ipt2socks ./package/waynesg/ipt2socks
cp -rf ../passwall_pkg/pdnsd-alt ./package/waynesg/pdnsd-alt
cp -rf ../passwall_pkg/trojan-plus ./package/waynesg/trojan-plus
cp -rf ../passwall_pkg/xray-plugin ./package/waynesg/xray-plugin
# Passwall 白名单
echo '
teamviewer.com
epicgames.com
dangdang.com
account.synology.com
ddns.synology.com
checkip.synology.com
checkip.dyndns.org
checkipv6.synology.com
ntp.aliyun.com
cn.ntp.org.cn
ntp.ntsc.ac.cn
' >>./package/waynesg/luci-app-passwall/root/usr/share/passwall/rules/direct_host
# Passwall2
cp -rf ../passwall2_luci/luci-app-passwall2 ./package/waynesg/luci-app-passwall2
sed -i 's/"PassWall 2"/"PassWall+"/g' ./package/waynesg/luci-app-passwall2/luasrc/controller/passwall2.lua
# 清理内存
cp -rf ../lede_luci/applications/luci-app-ramfree ./package/waynesg/luci-app-ramfree
# ServerChan 微信推送
# git clone -b master --depth 1 https://github.com/tty228/luci-app-serverchan.git package/waynesg/luci-app-serverchan
# Pushbot 推送
cp -rf ../lede_luci/applications/luci-app-pushbot ./package/waynesg/luci-app-pushbot
# ShadowsocksR Plus+ 依赖
rm -rf ./feeds/packages/net/shadowsocks-libev
cp -rf ../lede_pkg/net/shadowsocks-libev ./package/waynesg/shadowsocks-libev
cp -rf ../ssrp/redsocks2 ./package/waynesg/redsocks2
cp -rf ../ssrp/trojan ./package/waynesg/trojan
cp -rf ../ssrp/dns2tcp ./package/waynesg/dns2tcp
cp -rf ../ssrp/gn ./package/waynesg/gn
cp -rf ../ssrp/shadowsocksr-libev ./package/waynesg/shadowsocksr-libev
cp -rf ../ssrp/simple-obfs ./package/waynesg/simple-obfs
cp -rf ../ssrp/naiveproxy ./package/waynesg/naiveproxy
cp -rf ../ssrp/v2ray-core ./package/waynesg/v2ray-core
cp -rf ../ssrp/hysteria ./package/waynesg/hysteria
#cp -rf ../ssrp/sagernet-core ./package/waynesg/sagernet-core
rm -rf ./feeds/packages/net/xray-core
cp -rf ../ssrp/xray-core ./package/waynesg/xray-core
cp -rf ../ssrp/v2ray-plugin ./package/waynesg/v2ray-plugin
cp -rf ../ssrp/shadowsocks-rust ./package/waynesg/shadowsocks-rust
cp -rf ../ssrp/lua-neturl ./package/waynesg/lua-neturl
rm -rf ./feeds/packages/net/kcptun
cp -rf ../immortalwrt_pkg/net/kcptun ./feeds/packages/net/kcptun
ln -sf ../../../feeds/packages/net/kcptun ./package/feeds/packages/kcptun
# ShadowsocksR Plus+
cp -rf ../ssrp/luci-app-ssr-plus ./package/waynesg/luci-app-ssr-plus
sed -i 's/ShadowSocksR Plus+/SSRPlus+/g' package/waynesg/luci-app-ssr-plus/luasrc/controller/shadowsocksr.lua
rm -rf ./package/waynesg/luci-app-ssr-plus/po/zh_Hans
pushd package/waynesg
wget -qO - https://github.com/fw876/helloworld/commit/5bbf6e7.patch | patch -p1
popd
pushd package/waynesg/luci-app-ssr-plus
sed -i '/Clang.CN.CIDR/a\o:value("https://gh.404delivr.workers.dev/https://github.com/QiuSimons/Chnroute/raw/master/dist/chnroute/chnroute.txt", translate("QiuSimons/Chnroute"))' luasrc/model/cbi/shadowsocksr/advanced.lua
popd
# socat
cp -rf ../Lienol_pkg/luci-app-socat ./package/waynesg/luci-app-socat
sed -i 's/"Socat"/"IPv6转发"/g'  ./package/waynesg/luci-app-socat/luasrc/controller/socat.lua
sed -i '/socat\.config/d' feeds/packages/net/socat/Makefile
# 订阅转换
cp -rf ../immortalwrt_pkg/net/subconverter ./feeds/packages/net/subconverter
ln -sf ../../../feeds/packages/net/subconverter ./package/feeds/packages/subconverter
cp -rf ../immortalwrt_pkg/libs/jpcre2 ./feeds/packages/libs/jpcre2
ln -sf ../../../feeds/packages/libs/jpcre2 ./package/feeds/packages/jpcre2
cp -rf ../immortalwrt_pkg/libs/rapidjson ./feeds/packages/libs/rapidjson
ln -sf ../../../feeds/packages/libs/rapidjson ./package/feeds/packages/rapidjson
cp -rf ../immortalwrt_pkg/libs/libcron ./feeds/packages/libs/libcron
ln -sf ../../../feeds/packages/libs/libcron ./package/feeds/packages/libcron
cp -rf ../immortalwrt_pkg/libs/quickjspp ./feeds/packages/libs/quickjspp
ln -sf ../../../feeds/packages/libs/quickjspp ./package/feeds/packages/quickjspp
cp -rf ../immortalwrt_pkg/libs/toml11 ./feeds/packages/libs/toml11
ln -sf ../../../feeds/packages/libs/toml11 ./package/feeds/packages/toml11
# 网易云音乐解锁
git clone -b js --depth 1 https://github.com/UnblockNeteaseMusic/luci-app-unblockneteasemusic.git package/waynesg/UnblockNeteaseMusic
sed -i 's/"解除网易云音乐播放限制"/"网易音乐"/g' ./package/waynesg/UnblockNeteaseMusic/root/usr/share/luci/menu.d/luci-app-unblockneteasemusic.json
# rpcd
sed -i 's/option timeout 30/option timeout 60/g' package/system/rpcd/files/rpcd.config
sed -i 's#20) \* 1000#60) \* 1000#g' feeds/luci/modules/luci-base/htdocs/luci-static/resources/rpc.js
# USB 打印机
cp -rf ../lede_luci/applications/luci-app-usb-printer ./package/waynesg/luci-app-usb-printer
sed -i 's/"USB 打印服务器"/"打印服务"/g' ./package/waynesg/luci-app-usb-printer/po/zh-cn/usb-printer.po
# UU加速器
# cp -rf ../lede_luci/applications/luci-app-uugamebooster ./package/waynesg/luci-app-uugamebooster
# cp -rf ../lede_pkg/net/uugamebooster ./package/waynesg/uugamebooster
# VSSR
git clone -b master --depth 1 https://github.com/jerrykuku/luci-app-vssr.git package/waynesg/luci-app-vssr
sed -i 's/Hello World/VssrVPN/g' ./package/waynesg/luci-app-vssr/luasrc/controller/vssr.lua
git clone -b master --depth 1 https://github.com/jerrykuku/lua-maxminddb.git package/waynesg/lua-maxminddb
# 网络唤醒
cp -rf ../zxlhhyccc/zxlhhyccc/luci-app-wolplus ./package/waynesg/luci-app-wolplus
# 流量监视
git clone -b master --depth 1 https://github.com/brvphoenix/wrtbwmon.git package/waynesg/wrtbwmon
git clone -b master --depth 1 https://github.com/brvphoenix/luci-app-wrtbwmon.git package/waynesg/luci-app-wrtbwmon
# Zerotier
cp -rf ../immortalwrt_luci/applications/luci-app-zerotier ./feeds/luci/applications/luci-app-zerotier
sed -i 's/msgstr ""/msgstr "ZeroTier虚拟网络"/g' ./feeds/luci/applications/luci-app-zerotier/po/zh_Hans/zerotier.po
#cp -rf ../waynesg_pkg/move_2_services.sh ./feeds/luci/applications/luci-app-zerotier/move_2_services.sh
#chmod -R 755 ./feeds/luci/applications/luci-app-zerotier/move_2_services.sh
pushd feeds/luci/applications/luci-app-zerotier
#bash move_2_services.sh
popd
ln -sf ../../../feeds/luci/applications/luci-app-zerotier ./package/feeds/luci/luci-app-zerotier
rm -rf ./feeds/packages/net/zerotier
cp -rf ../immortalwrt_pkg/net/zerotier ./feeds/packages/net/zerotier
# jq
sed -i 's,9625784cf2e4fd9842f1d407681ce4878b5b0dcddbcd31c6135114a30c71e6a8,skip,g' feeds/packages/utils/jq/Makefile
# 中文编译及功能优化
cp -rf ../waynesg_pkg/openwrt-diy/addition-trans-zh ./package/waynesg/addition-trans-zh
sed -i 's,iptables-mod-fullconenat,iptables-nft +kmod-nft-fullcone,g' package/waynesg/addition-trans-zh/Makefile
# 高级设置
cp -rf ../waynesg_pkg/luci-app-advanced ./package/waynesg/luci-app-advanced
# Alist
git clone -b master --depth 1 https://github.com/sbwml/luci-app-alist package/waynesg/luci-app-alist
sed -i 's/"Alist 文件列表"/"Alist列表"/g' ./package/waynesg/luci-app-alist/luci-app-alist/po/zh-cn/alist.po
sed -i 's/"PKG_BUILD_DEPENDS:=golang\/host"/"PKG_BUILD_DEPENDS:=golang\/host upx\/host"/g' package/waynesg/luci-app-alist/alist/Makefile
# 定时设置
cp -rf ../waynesg_pkg/luci-app-autotimeset ./package/waynesg/luci-app-autotimeset
# Bypass
cp -rf ../waynesg_pkg/luci-app-bypass ./package/waynesg/luci-app-bypass
# CloudSpeedTest优选IP
cp -rf ../waynesg_pkg/luci-app-cloudflarespeedtest ./package/waynesg/luci-app-cloudflarespeedtest
sed -i 's/"Cloudflare速度测试"/"Cloudflare"/g' ./package/waynesg/luci-app-cloudflarespeedtest/po/zh-cn/cloudflarespeedtest.po
# 文件管理器
cp -rf ../waynesg_pkg/luci-app-fileassistant ./package/waynesg/luci-app-fileassistant
# 宽带测速
cp -rf ../waynesg_pkg/luci-app-netspeedtest ./package/waynesg/luci-app-netspeedtest
sed -i 's/"PKG_BUILD_DEPENDS:=golang\/host homebox\/host"/"PKG_BUILD_DEPENDS:=golang\/host homebox\/host upx\/host"/g' package/waynesg/luci-app-netspeedtest/homebox/Makefile
# 组播路由
cp -rf ../waynesg_pkg/luci-app-msd_lite ./package/waynesg/luci-app-msd_lite
sed -i 's/"MultiSD_Lite"/"组播路由"/g'  ./package/waynesg/luci-app-msd_lite/luasrc/controller/msd_lite.lua
cp -rf ../waynesg_pkg/luci-app-dependence/msd_lite ./package/waynesg/msd_lite
# 在线设备
cp -rf ../waynesg_pkg/luci-app-onliner ./package/waynesg/luci-app-onliner
# 设备信息监控
cp -rf ../lede_pkg/utils/smartmontools ./package/waynesg/smartmontools
cp -rf ../waynesg_pkg/luci-app-smartinfo ./package/waynesg/luci-app-smartinfo
# 网络接口图标
cp -rf ../waynesg_pkg/luci-app-tn-netports ./package/waynesg/luci-app-tn-netports
# TurboACC
#cp -rf ../waynesg_pkg/luci-app-turboacc ./package/waynesg/luci-app-turboacc
#sed -i 's/"Turbo ACC 网络加速"/"网络加速"/g' ./package/waynesg/luci-app-turboacc/po/zh-cn/turboacc.po
#cp -rf ../waynesg_pkg/luci-app-dependence/shortcut-fe ./package/waynesg/shortcut-fe
#cp -rf ../waynesg_pkg/luci-app-dependence/dnsforwarder ./package/waynesg/dnsforwarder
#cp -rf ../lede_pkg/net/dnsproxy ./package/waynesg/dnsproxy
#Others Menu Modify
sed -i 's/"Web 管理"/"Web管理"/g' `grep "Web 管理" -rl ./`
sed -i 's/"备份\/升级"/"备份升级"/g' `grep "备份\/升级" -rl ./`
#sed -i 's/"管理权"/"权限管理"/g' ./feeds/luci/modules/luci-base/po/zh_Hans/base.po
#sed -i 's/"重启"/"立即重启"/g' ./feeds/luci/modules/luci-base/po/zh_Hans/base.po
#sed -i '''s/'"系统"'/'"系统设置"'/g''' ./feeds/luci/modules/luci-base/po/zh_Hans/base.po
#sed -i 's/"挂载点"/"挂载路径"/g' ./feeds/luci/modules/luci-base/po/zh_Hans/base.po
#sed -i 's/"启动项"/"启动管理"/g' ./feeds/luci/modules/luci-base/po/zh_Hans/base.po
#sed -i 's/"软件包"/"软件管理"/g' ./feeds/luci/modules/luci-base/po/zh_Hans/base.po
#sed -i 's/"Terminal"/"命令终端"/g' ./feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
sed -i 's/"网络存储"/"存储"/g' `grep "网络存储" -rl ./`
sed -i 's/"实时流量监测"/"流量"/g' `grep "实时流量监测" -rl ./`
sed -i 's/"USB 打印服务器"/"打印服务"/g' `grep "USB 打印服务器" -rl ./`
sed -i 's/"带宽监控"/"监控"/g' `grep "带宽监控" -rl ./`
sed -i 's/"主机名"/"主机名称"/g' `grep "主机名" -rl ./`
sed -i 's/"接口"/"网络接口"/g' `grep "接口" -rl ./`


