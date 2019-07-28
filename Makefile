ARCHS := armv7 armv7s arm64 arm64e
TARGET := iphone:clang:12.2:9.0

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LowPowerCharging

$(TWEAK_NAME)_FILES = Tweak.x
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
$(TWEAK_NAME)_PRIVATE_FRAMEWORKS = CoreDuet

include $(THEOS_MAKE_PATH)/tweak.mk
