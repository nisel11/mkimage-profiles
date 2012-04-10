+icewm: use/x11/icewm; @:
+razorqt: use/x11/razorqt use/x11/lightdm; @:
+tde: use/x11/tde use/x11/kdm; @:

use/x11/xorg:
	@$(call add,THE_LISTS,xorg)

use/x11/wacom: use/x11/xorg
	@$(call add,THE_PACKAGES,xorg-drv-wacom xorg-drv-wizardpen)

use/x11/drm: use/x11/xorg
	@$(call add,THE_KMODULES,drm drm-radeon)

use/x11/3d-free: use/x11/drm
	@$(call add,THE_KMODULES,drm-nouveau)

### fglrx is broken with xorg-1.12 so far
use/x11/3d-proprietary: use/x11/xorg
	@$(call add,THE_KMODULES,fglrx nvidia)
	@$(call add,THE_PACKAGES,nvidia-settings nvidia-xconfig)
	@$(call add,THE_PACKAGES,fglrx_glx fglrx-tools)

### strictly speaking, runlevel5 should require a *dm, not vice versa
use/x11/runlevel5: use/x11/xorg
	@$(call add,THE_PACKAGES,installer-feature-runlevel5-stage3)

### xdm: see also #23108
use/x11/xdm: use/x11/runlevel5
	@$(call add,THE_PACKAGES,xdm installer-feature-no-xconsole)

### : some set()-like thing might be better?
use/x11/lightdm: use/x11/runlevel5
	@$(call add,THE_PACKAGES,lightdm)

use/x11/kdm: use/x11/runlevel5
	@$(call add,THE_PACKAGES,kdebase-kdm)

use/x11/gdm2.20: use/x11/runlevel5
	@$(call add,THE_PACKAGES,gdm2.20)

use/x11/icewm: use/x11/xorg
	@$(call add,THE_LISTS,$(call tags,icewm desktop))

use/x11/razorqt: use/x11/xorg
	@$(call add,THE_LISTS,$(call tags,razorqt desktop))

use/x11/tde: use/x11/xorg
	@$(call add,THE_LISTS,$(call tags,tde desktop))

use/x11/xfce: use/x11/xorg
	@$(call add,THE_LISTS,$(call tags,xfce desktop))
