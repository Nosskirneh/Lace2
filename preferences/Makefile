TARGET = iphone:clang:9.2

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = LacePrefs
LacePrefs_FILES = $(wildcard *.m)
LacePrefs_CFLAGS = -fobjc-arc
LacePrefs_INSTALL_PATH = /Library/PreferenceBundles
LacePrefs_FRAMEWORKS = UIKit
LacePrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/LacePrefs.plist$(ECHO_END)
