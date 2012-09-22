# alterator-based installer, second (livecd) stage
use/install2: use/stage2 sub/stage2@install2 use/metadata use/cleanup/installer
	@$(call add_feature)
	@$(call set,INSTALL2_PACKAGES,installer-distro-$$(INSTALLER)-stage2)
	@$(call add,INSTALL2_PACKAGES,branding-$$(BRANDING)-alterator)
	@$(call add,BASE_PACKAGES,branding-$$(BRANDING)-release)
	@$(call add,BASE_LISTS,$(call tags,basesystem))
	@$(call xport,BASE_BOOTLOADER)

use/install2/net: use/install2
	@$(call add,INSTALL2_PACKAGES,curl)

# modern free xorg drivers for mainstream hardware requires KMS support
use/install2/kms: use/stage2/kms
	@$(call add,BASE_KMODULES_REGEXP,drm.*)

# see also use/vmguest/kvm; qxl included in xorg pkglist
use/install2/kvm:
	@$(call add,INSTALL2_PACKAGES,spice-vdagent xorg-drv-qxl)

# filesystems handling
use/install2/fs: use/install2/xfs use/install2/jfs use/install2/reiserfs; @:

use/install2/xfs:
	@$(call add,INSTALL2_PACKAGES,xfsprogs)

use/install2/jfs:
	@$(call add,INSTALL2_PACKAGES,jfsutils)

use/install2/reiserfs:
	@$(call add,INSTALL2_PACKAGES,reiserfsprogs)
