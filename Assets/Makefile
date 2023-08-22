# ========================================================================================
# =============================== ASSET BUNDLE MAKEFILE ==================================
# ========================================================================================
#
# Helper Makefile to combine all assets in subdirectories into a single
# 'Bundle' file. Note that these assets are not compressed. This is a
# hacky workaround for not using .xcassets files and compiling everything
# outside of the Xcode ecosystem. The associated scripts ensure UI assets
# are build with correct @2x naming convention to ensure they are compatible
# with Retina displays
#
# Project Directory Structure
# |
# +-> Makefile (For Entire Project)
# +-> Assets
# |   |
# |   +-> Installer Template.dmg
# |   +-> Makefile (For Asset Bundle)
# |   |
# |   +-> UI Assets
# |   |   |
# |   |   +-> [ All UI assets used in the app as 1024x1024 PNGs]
# |   |   +-> Icons
# |   |   |   |
# |   |   |   +-> App Icon
# |   |   |   |   |
# |   |   |   |   +-> [ App Icon, as a 1024x1024 PNG ]
# |   |   |   +-> Status Bar Icons
# |   |   |   |
# |   |   |   +-> [ All icons used in the Status Bar as 1024x1024 PNGs ]
# |   |   +-> Installer Background
# |   |       |
# |   |       +-> Installer Background.png, an 828x512 PNG
# |   +-> UI ELement Mockups
# |       |
# |       +-> [ Supporting files used to created the 1024x1024 PNGs ]
# +-> Scripts
# |   |
# |   +-> createicns.sh
# |   +-> createplist.sh
# |   +-> createuiassets.sh
# |   +-> finderrename.scpt
# |   +-> finderrename.sh
# +-> Source
#     |
#     +-> Launcher
#     |   |
#     |   +-> Makefile (For Launcher Application)
#     |   +-> lib
#     |       |
#     |       +-> [ Launcher Application Supporting Libraries ]
#     |   +-> src
#     |       |
#     |       +-> [ Launcher Application Source Files ]
#     +-> Main
#         |
#         +-> Makefile (For Main Application)
#         +-> lib
#         |   |
#         |   +-> [ Main Application Supporting Libraries ]
#         +-> src
#             |
#             +-> [ Main Application Source Files ]
#
#
# Installer Template.dmg
# |
# +-> .DS_Store
# +-> .background
# |   |
# |   +-> background.png, an 828x512 PNG
# +-> Application Template
# |   |
# |   +-> [ Empty ]
# +-> Applications (An alias to /Applications)
#
#
# App Structure
# |
# +-> Contents
#     |
#     +-> Info.plist
#     +-> Library (Present when a helper launch-at-login application is required)
#     |   |
#     |   +-> LoginItems
#     |       |
#     |       +-> Contents
#     |           |
#     |           +-> Info.plist
#     |           +-> MacOS
#     |   	 |   |
#     |           |   +-> [ Compiled launcher utility binary ]
#     |           +-> Resources
#     |               |
#     |               +-> AppIcon.icns
#     +-> MacOS
#     |   |
#     |   +-> [ Compiled main app binary ]
#     +-> Resources
#	  |
#	  +-> AppIcon.icns
#	  +-> Assets.bundle
#	  |   |
#	  |   +-> Contents
#	  |   	  |
#	  |   	  +-> Info.plist
#	  |   	  +-> Resources
#	  |   	      |
#	  |   	      +-> AppIcon.icns
#	  |   	      +-> [ All other image and resource files required by the app ]
#	  +-> Defaults.plist (Contains application default settings)
#	  +-> App_Name.entitlements (Contains application entitlements, if used)
#
# ========================================================================================

SHELL = /bin/bash

MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
# make is bad at handling directories with spaces!
BUILD_PATH := $(shell dirname '$(MAKEFILE_PATH)')

BUILD_DIR_NAME := .build
BUILD_DIR := $(BUILD_PATH)/$(BUILD_DIR_NAME)
SCRIPTS_DIR := $(BUILD_PATH)/../Scripts

BUNDLE_NAME := "Assets"

BUNDLE_PATH := $(BUNDLE_NAME).bundle

INFO_PLIST := $(BUILD_DIR)/Info.plist

UI_ASSETS := $(BUILD_PATH)/"UI Assets"
UI_ASSET_SIZE := 24

STATUS_BAR_ICON := $(BUILD_PATH)/"UI Assets/Icons/Status Bar Icons/"
STATUS_ICON_SIZE := 18

APP_ICON := $(BUILD_PATH)/"UI Assets/Icons/App Icon/App Icon.png"

make: bundle


.PHONY : build-dir
build-dir :
	@if [ ! -d $(BUILD_DIR) ]; then \
		echo "Creating Bundle Build Directory..."; \
		mkdir $(BUILD_DIR); \
	fi


.PHONY : bundle
bundle: purge build-dir
	@echo "Creating Bundle..."
	@mkdir -p $(BUILD_DIR)/$(BUNDLE_PATH)/Contents/Resources
	@echo "Creating App Icon..."
	@-$(SCRIPTS_DIR)/createicns.sh $(APP_ICON) $(BUILD_DIR) 2> /dev/null
	@echo "Moving App Icon into place..."
	@-mv $(BUILD_DIR)/*.icns $(BUILD_DIR)/$(BUNDLE_PATH)/Contents/Resources 2> /dev/null
	@echo "Creating Status Bar Icon..."
	@-$(SCRIPTS_DIR)/createuiassets.sh $(STATUS_BAR_ICON) $(BUILD_DIR) $(STATUS_ICON_SIZE) 2> /dev/null
	@echo "Moving Status Bar Icon into place..."
	@-mv $(BUILD_DIR)/Assets/*.tiff $(BUILD_DIR)/$(BUNDLE_PATH)/Contents/Resources 2> /dev/null
	@echo "Creating UI Assets..."
	@-$(SCRIPTS_DIR)/createuiassets.sh $(UI_ASSETS) $(BUILD_DIR) $(UI_ASSET_SIZE) 2> /dev/null
	@echo "Moving UI Assets into place..."
	@-mv $(BUILD_DIR)/Assets/*.tiff $(BUILD_DIR)/$(BUNDLE_PATH)/Contents/Resources 2> /dev/null
	@echo "Cleaning Build Directory..."
	@rm -rf $(BUILD_DIR)/Assets


.PHONY : clean
clean:
	@echo "Cleaning up Asset Bundle Files..."
	@rm -rf $(BUILD_DIR)


.PHONY : purge
purge:
	@echo "Purging Asset Bundle Files..."
	@rm -rf $(BUILD_DIR)
	@rm -rf $(BUNDLE_PATH)
