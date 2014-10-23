export THEOS=/var/theos
export ARCHS = armv7 arm64
export TARGET = iphone:clang:7.0:7.0
export SDKVERSION = 7.0

include theos/makefiles/common.mk

APPLICATION_NAME = FTLSaver
FTLSaver_FILES = main.m FTLSaver.mm RightViewController.mm LeftViewController.mm UIAlertView+Blocks.m GameSaver.mm
FTLSaver_FRAMEWORKS = Foundation UIKit CoreGraphics

include $(THEOS_MAKE_PATH)/application.mk
