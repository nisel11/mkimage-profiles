# various VM guest modules/tools
ifeq (,$(filter-out i586 x86_64 aarch64 armh,$(ARCH)))

use/vmguest:
	@$(call add_feature)

# NB: only reasonable for X11-bearing images
# see also use/install2/kvm
use/vmguest/kvm: use/vmguest
	@$(call add,THE_PACKAGES,qemu-guest-agent)

ifeq (,$(filter-out i586 x86_64,$(ARCH)))

use/vmguest/base: use/vmguest/vbox use/vmguest/vmware use/vmguest/kvm; @:
use/vmguest/complete: use/vmguest/base \
	use/vmguest/vbox/x11 use/vmguest/vmware/x11 use/vmguest/kvm/x11; @:

use/vmguest/vbox: use/vmguest
	@$(call add,THE_KMODULES,virtualbox-addition vboxguest)

use/vmguest/vbox/x11: use/vmguest/vbox
	@$(call add,THE_KMODULES,drm)
	@$(call add,THE_PACKAGES,virtualbox-guest-additions)

use/vmguest/kvm/x11: use/vmguest/kvm
	@$(call add,THE_PACKAGES,spice-vdagent xorg-drv-qxl)

# see also use/install2/vmware
use/vmguest/vmware:
	@$(call add,THE_KMODULES,vmware)
	@$(call add,THE_KMODULES,scsi)	# mptspi.ko
	@$(call add,THE_PACKAGES,open-vm-tools)

use/vmguest/vmware/x11: use/vmguest/vmware
	@$(call add,THE_PACKAGES,xorg-drv-vmware xorg-drv-vmmouse open-vm-tools-desktop)

+vmguest: use/vmguest/complete; @:

else

# non-x86
+vmguest: use/vmguest/kvm; @:

endif

else

# kvm-unsupported guest arch
+vmguest: ;@:

endif
