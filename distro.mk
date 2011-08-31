# this makefile is designed to be included in toplevel one
ifndef BUILDDIR
$(error BUILDDIR not defined)
endif

# step 2: build up distribution's configuration

# NB: distro/ targets should be defined in this file,
# see toplevel Makefile's $(DISTROS) assignment
CONFIG = $(BUILDDIR)/distcfg.mk

# collect use/% (source initial feature snippets)
-include features.in/*/config.mk

# put(), add(), set(), try(), tags():
# package list names are considered relative to pkg/lists/;
# tags can do boolean expressions: (tag1 && !(tag2 || tag3))
include functions.mk

# distro/.%, sub/.%, boot/%
include libdistro.mk

# bootloader test target; requires recent mkimage to build
distro/syslinux: distro/.init distro/.branding sub/stage1 \
	use/syslinux use/syslinux/localboot.cfg \
	use/syslinux/ui-vesamenu use/hdt use/memtest use/dos

#  $(VAR) will be substituted before writing them to $(CONFIG);
# $$(VAR) will remain unsubstituted util $(CONFIG) is included
#         and their value requested (so the variable referenced
#         can change its value during configuration _before_
#         it's actually used); just peek inside $(CONFIG) ;-)
# BASE_PACKAGES, BASE_LISTS, MAIN_PACKAGES, MAIN_LISTS: see sub.in/main/

# live images

distro/live: distro/.base use/live use/syslinux/ui-menu
distro/rescue: distro/.base use/rescue use/syslinux/ui-menu

# something actually useful (as a network-only installer)
# NB: doesn't carry stage3 thus cannot use/bootloader
distro/installer: distro/.base use/install2
	@$(call set,INSTALLER,altlinux-generic)
	@$(call set,STAGE1_KMODULES_REGEXP,drm.*)	# for KMS

# server distributions

distro/server-base: distro/installer sub/main \
	use/syslinux/ui-menu use/memtest use/bootloader/grub
	@$(call add,BASE_LISTS,server-base)

distro/server-mini: distro/server-base
	@$(call set,KFLAVOURS,el-smp)
	@$(call add,KMODULES,e1000e igb)
	@$(call add,BASE_LISTS,\
		$(call tags,base && (server || network || security || pkg)))
	@$(call add,BASE_LISTS,$(call tags,extra network))

distro/server-ovz: distro/server-base use/hdt use/rescue use/firmware/server
	@$(call set,STAGE1_KFLAVOUR,std-def)
	@$(call set,KFLAVOURS,std-def ovz-el)
	@$(call add,KMODULES,bcmwl e1000e igb ndiswrapper rtl8168 rtl8192)
	@$(call add,KMODULES,ipset ipt-netflow opendpi pf_ring xtables-addons)
	@$(call add,KMODULES,drbd83 kvm)
	@$(call add,BASE_LISTS,ovz-server)
	@$(call add,BASE_LISTS,$(call tags,base server))
	@$(call add,MAIN_LISTS,kernel-wifi)
	@$(call add,GROUPS,dns-server http-server ftp-server kvm-server)
	@$(call add,GROUPS,ipmi mysql-server dhcp-server mail-server)
	@$(call add,GROUPS,monitoring diag-tools)

# desktop distributions

distro/desktop-base: distro/installer sub/main \
	use/syslinux/ui-vesamenu use/x11/xorg use/bootloader/grub

distro/icewm: distro/desktop-base use/lowmem use/x11/xdm use/x11/runlevel5 use/bootloader/lilo
	@$(call add,BASE_LISTS,$(call tags,icewm desktop))

# NB: if there are too many screens above, it might make sense to distro.d/
