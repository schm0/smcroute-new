#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk



PKG_NAME:=smcroute-new
PKG_VERSION:=2.4.2
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/troglobit/smcroute.git
PKG_SOURCE_VERSION:=df92ba510eaa521c75e0cf20d7c2269724a8fd94
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz

PKG_LICENSE:=GPL-2.0+

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=autoreconf

PKG_CONFIG_DEPENDS:= CONFIG_PACKAGE_smcroute-new_confsupport \
	CONFIG_PACKAGE_smcroute-new_libcap \
	CONFIG_PACKAGE_smcroute-new_client \
	CONFIG_PACKAGE_smcroute-new_mrdisc

include $(INCLUDE_DIR)/package.mk

define Package/smcroute-new
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Routing and Redirection
	TITLE:=Static Multicast Routing Daemon
	URL:=http://troglobit.com/smcroute.html
	MAINTAINER:=nobody
	DEPENDS:=+PACKAGE_smcroute-new_libcap:libcap
endef

define Package/smcroute-new/description
	SMCRoute is a command line tool to manipulate the multicast routes of the Linux kernel.
endef


define Package/smcroute-new/config
	if PACKAGE_smcroute-new
	config PACKAGE_smcroute-new_confsupport
		bool "Enable /etc/smcroute.conf support"
		default y
	config PACKAGE_smcroute-new_libcap
		bool "Enable libcap, -p USER:GROUP drop-privs support"
		default y
	config PACKAGE_smcroute-new_client
		bool "Build with client (smcroutectl)"
		default n
	config PACKAGE_smcroute-new_mrdisc
		bool "Enable IPv4 multicast router discovery"
		default n
	endif
endef


CONFIGURE_ARGS += \
	$(if $(CONFIG_IPV6),,--disable-ipv6) \

CONFIGURE_ARGS += \
	$(if $(CONFIG_PACKAGE_smcroute-new_confsupport),,--disable-config) \
	$(if $(CONFIG_PACKAGE_smcroute-new_libcap),,--without-libcap) \
	$(if $(CONFIG_PACKAGE_smcroute-new_client),,--disable-client) \
	$(if $(CONFIG_PACKAGE_smcroute-new_mrdisc),--enable-mrdisc) \


define Package/smcroute-new/conffiles
/etc/smcroute/smcroute.conf
endef


define Package/smcroute-new/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/etc/smcroute
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/smcroute.conf $(1)/etc/smcroute/smcroute.conf
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/smcrouted $(1)/usr/sbin/
	$(INSTALL_BIN) ./files/smcroute.init $(1)/etc/init.d/smcroute

  	ifeq ($(CONFIG_PACKAGE_smcroute-new_client),y)
		$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/smcroutectl $(1)/usr/sbin/
  	endif

endef


$(eval $(call BuildPackage,smcroute-new))
