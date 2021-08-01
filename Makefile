ARCHS = arm64 arm64e
TARGET := iphone:clang:latest:11.0
INSTALL_TARGET_PROCESSES = SpringBoard

GO_EASY_ON_ME = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = earthpaper

earthpaper_PRIVATE_FRAMEWORKS = SpringBoardFoundation SpringBoardUIServices

earthpaper_FILES = Tweak.x fetcher.x setWallpaper.m LockScreenHooks.x HomeScreenHooks.x
earthpaper_CFLAGS = -fobjc-arc
earthpaper_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
