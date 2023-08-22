# ========================================================================================
# ============================== ENTIRE PROJECT MAKEFILE =================================
# ========================================================================================
#
# TODO(toru173): Deal with case wherein user has a special character in the parent directory
# TODO(toru173): Clean out Installer Template and choose a nicer size of background image
#
# This Makefile will take a directory structure as below, and
# output a macOS application or installer that displays interactive
# alerts but is derived from a shell script. Note that this is not
# the best way of doing things, but it works as a hacky way
# to build an app outside of the Xcode ecosystem
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
# |   +-> App Scripts
# |       |
# |       +-> main.sh
# |       +-> [ Additional scripts as required ]
# +-> Source
#     |
#     +-> Launcher
#     |   |
#     |   +-> Makefile (For Launcher Application)
#     |   +-> lib
#     |   |   |
#     |   |   +-> [ Launcher Application Supporting Libraries ]
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
# +-> .DS_Store (Required)
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
#     +-> _CodeSignature
#	  |   |
#	  |   +-> [ Files as required for a signed application ]
#     +-> Library (Present when a helper launch-at-login application is required)
#     |   |
#     |   +-> LoginItems
#     |       |
#     |       +-> Contents
#     |           |
#     |           +-> Info.plist
#     |           +-> MacOS
#     |   	      |   |
#     |           |   +-> [ Compiled launcher utility binary ]
#     |           +-> Resources
#     |               |
#     |               +-> AppIcon.icns
#     +-> MacOS
#     |   |
#     |   +-> [ Compiled Toolbox Binary ]
#     |   +-> main.sh
#     |   +-> [additional scripts as required].sh
#     +-> Resources
#	      |
#	      +-> AppIcon.icns
#	      +-> Assets.bundle
#	      |   |
#         |   +-> _CodeSignature
#	      |   +-> [ Files as required for a signed bundle ]
#	      |   +-> Contents
#	      |   	  |
#	      |   	  +-> Info.plist
#	      |   	  +-> Resources
#	      |   	      |
#	      |   	      +-> AppIcon.icns
#	      |   	      +-> [ All other image and resource files required by the app ]
#	      +-> [ Additional Scripts, as required ]
#	      +-> Defaults.plist (Contains application default settings)
#	      +-> App_Name.entitlements (Contains application entitlements, if used)
#
# ========================================================================================

SHELL = /bin/bash

BIN_NAME := uitoolbox
MAIN_SCRIPT := main.sh
APP_NAME := "Example App"
BUNDLE_ID := local.$(shell whoami).$(APP_NAME)
MINSUPPORTEDOS := 11
VERSION := "0.0.1"

BUILD_UNIVERSAL := true
# If not building a univerale app, build options include x86_64 and arm64
BUILD_ARCHITECTURE := x86_64

BUILD_LAUNCHER := false

CODESIGN_BUILD := true
CODESIGN_ID := "-"
ADD_ENTITLEMENTS := true
USE_EMBEDDED_INFO_PLIST := true

ifeq ($(USE_EMBEDDED_INFO_PLIST),true)
EMBEDDED_INFO_PLIST := true
endif

# Optional declerations in for the Info.Plist File in the Main Application

# Runtime configurable settings used in Config.plist go here


MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
# make is bad at handling directories with spaces!
BUILD_PATH = $(shell dirname '$(MAKEFILE_PATH)')

BUILD_DIR_NAME := .build
BUILD_DIR := $(BUILD_PATH)/$(BUILD_DIR_NAME)
SCRIPTS_DIR := $(BUILD_PATH)/Scripts
APP_SCRIPTS_DIR := $(SCRIPTS_DIR)/"App Scripts"
ASSETS_DIR := $(BUILD_PATH)/Assets
ASSETS_NAME := "Assets"
ASSETS_BUNDLE_FILENAME := $(ASSETS_NAME).bundle
MAIN_SRC_DIR := $(BUILD_PATH)/Source/Main
LAUNCHER_SRC_DIR := $(BUILD_PATH)/Source/Launcher

DEFAULTS_PLIST := $(BUILD_DIR)/Defaults.plist

ENTITLEMENTS_FILENAME := $(shell echo $(APP_NAME) | tr -d ' ').entitlements
ENTITLEMENTS_PLIST := $(BUILD_DIR)/$(ENTITLEMENTS_FILENAME)

MOUNTPATH := $(BUILD_DIR)/mnt

INSTALLER_TEMPLATE := $(ASSETS_DIR)/"Installer Template.dmg"
INSTALLER_NAME := "Install "$(APP_NAME)
INSTALLER_BACKGROUND := $(ASSETS_DIR)/"UI Assets/Installer Background/Installer Background.png"


make : installer


.PHONY : build-dir
build-dir :
	@if [ ! -d $(BUILD_DIR) ]; then \
		echo "Creating Project Build Directory..."; \
		mkdir $(BUILD_DIR); \
	fi
	
	
.PHONY : main-bin
main-bin : INFO_PLIST = $(BUILD_DIR)/main-info.plist
main-bin : INFO_PLIST_ARGS = $(if $(EMBEDDED_INFO_PLIST),$(MAIN_SRC_DIR)/$(BUILD_DIR_NAME)/Info.plist)
main-bin : build-dir main-info-plist
	@echo "Making Toolbox Binary..."
	@if [ $(USE_EMBEDDED_INFO_PLIST) = true ]; then \
		make -C $(MAIN_SRC_DIR) build-dir; \
		cp $(INFO_PLIST) $(MAIN_SRC_DIR)/$(BUILD_DIR_NAME)/Info.plist; \
	fi
	@if [ $(BUILD_UNIVERSAL) = true ]; then \
		make -C $(MAIN_SRC_DIR) $(BIN_NAME).universal.bin INFO_PLIST=$(INFO_PLIST_ARGS); \
	else \
		if [ $(BUILD_ARCHITECTURE) = arm64 ]; then \
			make -C $(MAIN_SRC_DIR) $(BIN_NAME).arm64.bin INFO_PLIST=$(INFO_PLIST_ARGS); \
		else \
			make -C $(MAIN_SRC_DIR) $(BIN_NAME).x86_64.bin INFO_PLIST=$(INFO_PLIST_ARGS); \
		fi; \
	fi
	@echo "Copying Toolbox Binary into Project Build Directory..."
	@cp $(MAIN_SRC_DIR)/$(BUILD_DIR_NAME)/$(BIN_NAME).bin $(BUILD_DIR)
	@if [ $(CODESIGN_BUILD) = true ]; then \
		echo "Signing Toolbox Binary..."; \
		codesign -s $(CODESIGN_ID) --force $(BUILD_DIR)/$(BIN_NAME).bin &> /dev/null; \
	fi


.PHONY : main-bin-debug
main-bin-debug : INFO_PLIST = $(BUILD_DIR)/main-info.plist
main-bin-debug : INFO_PLIST_ARGS = $(if $(EMBEDDED_INFO_PLIST),$(MAIN_SRC_DIR)/$(BUILD_DIR_NAME)/Info.plist)
main-bin-debug : build-dir main-info-plist
	@echo "Making Toolbox Binary with Debug Options..."
	@if [ $(USE_EMBEDDED_INFO_PLIST) = true ]; then \
		make -C $(MAIN_SRC_DIR) build-dir; \
		cp $(INFO_PLIST) $(MAIN_SRC_DIR)/$(BUILD_DIR_NAME)/Info.plist; \
	fi
	@if [ $(BUILD_UNIVERSAL) = true ]; then \
		make -C $(MAIN_SRC_DIR) $(BIN_NAME).universal.debug INFO_PLIST=$(INFO_PLIST_ARGS); \
	else \
		if [ $(BUILD_ARCHITECTURE) = arm64 ]; then \
			make -C $(MAIN_SRC_DIR) $(BIN_NAME).arm64.debug INFO_PLIST=$(INFO_PLIST_ARGS); \
		else \
			make -C $(MAIN_SRC_DIR) $(BIN_NAME).x86_64.debug INFO_PLIST=$(INFO_PLIST_ARGS); \
		fi; \
	fi
	@echo "Copying Toolbox Binary into Project Build Directory..."
	@cp $(MAIN_SRC_DIR)/$(BUILD_DIR_NAME)/$(BIN_NAME).bin $(BUILD_DIR)
	@if [ $(CODESIGN_BUILD) = true ]; then \
		echo "Signing Toolbox Binary..."; \
		codesign -s $(CODESIGN_ID) --force $(BUILD_DIR)/$(BIN_NAME).bin &> /dev/null ; \
	fi


.PHONY : launcher-bin
launcher-bin : INFO_PLIST = $(BUILD_DIR)/launcher-info.plist
launcher-bin : INFO_PLIST_ARGS = $(if $(EMBEDDED_INFO_PLIST),$(LAUNCHER_SRC_DIR)/$(BUILD_DIR_NAME)/Info.plist)
launcher-bin : BIN_NAME := $(BIN_NAME)launcher
launcher-bin : build-dir launcher-info-plist
	@echo "Making Launcher Binary..."
	@if [ $(USE_EMBEDDED_INFO_PLIST) = true ]; then \
		make -C $(LAUNCHER_SRC_DIR) build-dir; \
		cp $(INFO_PLIST) $(LAUNCHER_SRC_DIR)/$(BUILD_DIR_NAME)/Info.plist; \
	fi
	@if [ $(BUILD_UNIVERSAL) = true ]; then \
		make -C $(LAUNCHER_SRC_DIR) $(BIN_NAME).universal.bin INFO_PLIST=$(INFO_PLIST_ARGS); \
	else \
		if [ $(BUILD_ARCHITECTURE) = arm64 ]; then \
			make -C $(LAUNCHER_SRC_DIR) $(BIN_NAME).arm64.bin INFO_PLIST=$(INFO_PLIST_ARGS); \
		else \
			make -C $(LAUNCHER_SRC_DIR) $(BIN_NAME).x86_64.bin INFO_PLIST=$(INFO_PLIST_ARGS); \
		fi; \
	fi
	@echo "Copying Launcher Binary into Project Build Directory..."
	@cp $(LAUNCHER_SRC_DIR)/$(BUILD_DIR_NAME)/$(BIN_NAME).bin $(BUILD_DIR)
	@if [ $(CODESIGN_BUILD) = true ]; then \
		echo "Signing Launcher Binary..."; \
		codesign -s $(CODESIGN_ID) --force $(BUILD_DIR)/$(BIN_NAME).bin; \
	fi


.PHONY : launcher-bin-debug
launcher-bin-debug : INFO_PLIST = $(BUILD_DIR)/launcher-info.plist
launcher-bin-debug : INFO_PLIST_ARGS = $(if $(EMBEDDED_INFO_PLIST),$(LAUNCHER_SRC_DIR)/$(BUILD_DIR_NAME)/Info.plist)
launcher-bin-debug : BIN_NAME := $(BIN_NAME)launcher
launcher-bin-debug : build-dir
	@echo "Making Launcher Binary with Debug Options..."
	@if [ $(USE_EMBEDDED_INFO_PLIST) = true ]; then \
		make -C $(LAUNCHER_SRC_DIR) build-dir; \
		cp $(INFO_PLIST) $(LAUNCHER_SRC_DIR)/$(BUILD_DIR_NAME)/Info.plist; \
	fi
	@if [ $(BUILD_UNIVERSAL) = true ]; then \
		make -C $(LAUNCHER_SRC_DIR) $(BIN_NAME).universal.debug INFO_PLIST=$(INFO_PLIST_ARGS); \
	else \
		if [ $(BUILD_ARCHITECTURE) = arm64 ]; then \
			make -C $(LAUNCHER_SRC_DIR) $(BIN_NAME).arm64.debug INFO_PLIST=$(INFO_PLIST_ARGS); \
		else \
			make -C $(LAUNCHER_SRC_DIR) $(BIN_NAME).x86_64.debug INFO_PLIST=$(INFO_PLIST_ARGS); \
		fi; \
	fi
	@echo "Copying Launcher Binary into Project Build Directory..."
	@cp $(LAUNCHER_SRC_DIR)/$(BUILD_DIR_NAME)/$(BIN_NAME).bin $(BUILD_DIR)
	@if [ $(CODESIGN_BUILD) = true ]; then \
		echo "Signing Launcher Binary..."; \
		codesign -s $(CODESIGN_ID) --force $(BUILD_DIR)/$(BIN_NAME).bin; \
	fi
	
.PHONY : ui-assets
ui-assets : INFO_PLIST = $(BUILD_DIR)/assets-info.plist
ui-assets : build-dir assets-info-plist
	@if [ ! -d $(BUILD_DIR)/$(ASSETS_BUNDLE_FILENAME) ]; then \
			echo "Running 'MAKE' for UI Assets..."; \
			make -C $(ASSETS_DIR) bundle; \
			echo "Moving UI Assets into Project Build Directory..."; \
			mv $(ASSETS_DIR)/$(BUILD_DIR_NAME)/$(ASSETS_BUNDLE_FILENAME) $(BUILD_DIR); \
			echo "Moving Assets Info.plist into place..." ; \
			mv $(INFO_PLIST) $(BUILD_DIR)/$(ASSETS_BUNDLE_FILENAME)/Contents/Info.plist ; \
	else \
		echo "Assets bundle exists. Not rebuilding assets..." ; \
	fi
	@if [ $(CODESIGN_BUILD) = true ]; then \
		echo "Signing Asset Bundle..."; \
		codesign -s $(CODESIGN_ID) --force $(BUILD_DIR)/$(ASSETS_BUNDLE_FILENAME) &> /dev/null; \
	fi


.PHONY : assets-info-plist
assets-info-plist : INFO_PLIST = $(BUILD_DIR)/assets-info.plist
assets-info-plist : build-dir
	@echo "Creating and Populating Assets Info.plist..."
	@$(SCRIPTS_DIR)/createplist.sh $(INFO_PLIST) # Create empty Info.INFO_PLIST
	@plutil -insert CFBundleName -string $(ASSETS_NAME) $(INFO_PLIST)
	@plutil -insert CFBundleDisplayName -string $(ASSETS_NAME) $(INFO_PLIST)
	@plutil -insert CFBundlePackageType -string "BNDL" $(INFO_PLIST)
	@plutil -insert CFBundleIdentifier -string $(BUNDLE_ID).assets $(INFO_PLIST)
	@plutil -insert CFBundleVersion -string $(VERSION) $(INFO_PLIST)
	@plutil -insert CFBundleShortVersionString -string $(VERSION) $(INFO_PLIST)


.PHONY : main-info-plist
main-info-plist : INFO_PLIST = $(BUILD_DIR)/main-info.plist
main-info-plist : build-dir
	@echo "Creating and Populating Main App Info.plist..."
	@$(SCRIPTS_DIR)/createplist.sh $(INFO_PLIST) # Create empty Info.plist
	@plutil -insert CFBundleIconFile -string "AppIcon" $(INFO_PLIST)
	@plutil -insert CFBundleIconName -string "AppIcon" $(INFO_PLIST)
	@plutil -insert CFBundlePackageType -string "APPL" $(INFO_PLIST)
	@plutil -insert CFBundleExecutable -string $(MAIN_SCRIPT) $(INFO_PLIST)
	@plutil -insert CFBundleName -string $(APP_NAME) $(INFO_PLIST)
	@plutil -insert CFBundleDisplayName -string $(APP_NAME) $(INFO_PLIST)
	@plutil -insert CFBundleIdentifier -string $(BUNDLE_ID) $(INFO_PLIST)
	@plutil -insert CFBundleVersion -string $(VERSION) $(INFO_PLIST)
	@plutil -insert CFBundleShortVersionString -string $(VERSION) $(INFO_PLIST)
	@plutil -insert LSMinimumSystemVersion -string $(MINSUPPORTEDOS) $(INFO_PLIST)
	@plutil -insert NSHighResolutionCapable -bool YES $(INFO_PLIST)


.PHONY : launch-info-plist
launcher-info-plist : INFO_PLIST = $(BUILD_DIR)/launcher-info.plist
launcher-info-plist : build-dir
	@echo "Creating and Populating Launcher App Info.plist..."
	@$(SCRIPTS_DIR)/createplist.sh $(INFO_PLIST) # Create empty Info.plist
	@plutil -insert CFBundleIconFile -string "AppIcon" $(INFO_PLIST)
	@plutil -insert CFBundleIconName -string "AppIcon" $(INFO_PLIST)
	@plutil -insert CFBundlePackageType -string "APPL" $(INFO_PLIST)
	@plutil -insert CFBundleExecutable -string $(BIN_NAME) $(INFO_PLIST)
	@plutil -insert CFBundleName -string $(APP_NAME) $(INFO_PLIST)
	@plutil -insert CFBundleDisplayName -string $(APP_NAME) $(INFO_PLIST)
	@plutil -insert CFBundleIdentifier -string $(BUNDLE_ID).launcher $(INFO_PLIST)
	@plutil -insert CFBundleVersion -string $(VERSION) $(INFO_PLIST)
	@plutil -insert CFBundleShortVersionString -string $(VERSION) $(INFO_PLIST)
	@plutil -insert LSBackgroundOnly -bool YES $(INFO_PLIST)
	@plutil -insert LSMinimumSystemVersion -string $(MINSUPPORTEDOS) $(INFO_PLIST)
	@plutil -insert NSSupportsSuddenTermination -bool YES $(INFO_PLIST)


# Any application defaults should be added here using plutil
.PHONY : defaults-plist
defaults-plist : build-dir
	@echo "Creating and Populating Defaults.plist..."
	@$(BUILD_PATH)/Scripts/createplist.sh $(DEFAULTS_PLIST) # Create empty Defaults.plist


# We need to use PlistBuddy instead of plutil here because plutil doesn't like the reverse-dns style entitlements
.PHONY : entitlements-plist
entitlements-plist : build-dir
	@if [ $(ADD_ENTITLEMENTS) = true ]; then \
		echo "Creating and Populating Entitlements plist..."; \
		$(BUILD_PATH)/Scripts/createplist.sh $(ENTITLEMENTS_PLIST); \
		/usr/libexec/PlistBuddy -c "add com.apple.security.app-sandbox bool YES" $(ENTITLEMENTS_PLIST); \
		/usr/libexec/PlistBuddy -c "add com.apple.security.files.user-selected.read-write bool YES" $(ENTITLEMENTS_PLIST); \
	else \
		echo "Entitlements not enabled. Not creating Entitlements file..."; \
	fi


.PHONY : main-app
main-app : INFO_PLIST = $(BUILD_DIR)/main-info.plist
main-app : build-dir ui-assets main-info-plist
	@echo "Creating Main App..."
	@mkdir -p $(BUILD_DIR)/$(APP_NAME).app/Contents/{MacOS,Resources}
	@echo "Running 'MAKE' for Toolbox Binary..."
	@make -C $(BUILD_PATH) main-bin
	@echo "Moving Toolbox Binary into Place..."
	@mv $(BUILD_DIR)/$(BIN_NAME).bin $(BUILD_DIR)/$(APP_NAME).app/Contents/Resources/$(BIN_NAME)
	@echo "Linking against Toolbox Binary..."
	@ln -s ../Resources/$(BIN_NAME) $(BUILD_DIR)/$(APP_NAME).app/Contents/MacOS/save
	@ln -s ../Resources/$(BIN_NAME) $(BUILD_DIR)/$(APP_NAME).app/Contents/MacOS/open
	@ln -s ../Resources/$(BIN_NAME) $(BUILD_DIR)/$(APP_NAME).app/Contents/MacOS/alert
	@ln -s ../Resources/$(BIN_NAME) $(BUILD_DIR)/$(APP_NAME).app/Contents/MacOS/menu
	@echo "Moving Scripts into Place..."
	@-cp $(APP_SCRIPTS_DIR)/* $(BUILD_DIR)/$(APP_NAME).app/Contents/MacOS/
	@echo "Copying UI Assets into place..."
	@mv $(BUILD_DIR)/$(ASSETS_BUNDLE_FILENAME) $(BUILD_DIR)/$(APP_NAME).app/Contents/Resources/
	@echo "Copying App Icon into place..."
	@-cp $(BUILD_DIR)/$(APP_NAME).app/Contents/Resources/$(ASSETS_BUNDLE_FILENAME)/Contents/Resources/AppIcon.icns \
		$(BUILD_DIR)/$(APP_NAME).app/Contents/Resources/ 2> /dev/null
	@echo "Moving Main App Info.plist into place..."
	@mv $(INFO_PLIST) $(BUILD_DIR)/$(APP_NAME).app/Contents/Info.plist
	@if [ $(CODESIGN_BUILD) = true ]; then \
		echo "Signing Main App..."; \
		codesign -s $(CODESIGN_ID) --force $(BUILD_DIR)/$(APP_NAME).app; \
	fi
	

.PHONY : main-app-debug
main-app-debug : APP_NAME := $(APP_NAME)" - Debug"
main-app-debug : INFO_PLIST = $(BUILD_DIR)/main-info.plist
main-app-debug : build-dir ui-assets main-info-plist
	@echo "Creating Main App with Debug Options..."
	@mkdir -p $(BUILD_DIR)/$(APP_NAME).app/Contents/{MacOS,Resources}
	@echo "Running 'MAKE' for Toolbox Binary with Debug Options..."
	@make -C $(BUILD_PATH) main-bin-debug
	@echo "Moving Toolbox Binary into Place..."
	@mv $(BUILD_DIR)/$(BIN_NAME).bin $(BUILD_DIR)/$(APP_NAME).app/Contents/Resources/$(BIN_NAME)
	@echo "Moving Scripts into Place..."
	@-cp $(APP_SCRIPTS_DIR)/* $(BUILD_DIR)/$(APP_NAME).app/Contents/MacOS/
	@echo "Linking against Toolbox Binary..."
	@ln -s ../Resources/$(BIN_NAME) $(BUILD_DIR)/$(APP_NAME).app/Contents/MacOS/save
	@ln -s ../Resources/$(BIN_NAME) $(BUILD_DIR)/$(APP_NAME).app/Contents/MacOS/open
	@ln -s ../Resources/$(BIN_NAME) $(BUILD_DIR)/$(APP_NAME).app/Contents/MacOS/alert
	@ln -s ../Resources/$(BIN_NAME) $(BUILD_DIR)/$(APP_NAME).app/Contents/MacOS/menu
	@echo "Copying UI Assets into place..."
	@mv $(BUILD_DIR)/$(ASSETS_BUNDLE_FILENAME) $(BUILD_DIR)/$(APP_NAME).app/Contents/Resources/
	@echo "Copying App Icon into place..."
	@-cp $(BUILD_DIR)/$(APP_NAME).app/Contents/Resources/$(ASSETS_BUNDLE_FILENAME)/Contents/Resources/AppIcon.icns \
		$(BUILD_DIR)/$(APP_NAME).app/Contents/Resources/ 2> /dev/null
	@echo "Moving Main App Info.plist into place..."
	@mv $(INFO_PLIST) $(BUILD_DIR)/$(APP_NAME).app/Contents/Info.plist
	@if [ $(CODESIGN_BUILD) = true ]; then \
		echo "Signing Main App..."; \
		codesign -s $(CODESIGN_ID) --force $(BUILD_DIR)/$(APP_NAME).app; \
	fi


.PHONY : launcher-app
launcher-app : APP_NAME := $(BIN_NAME)launcher
launcher-app : BIN_NAME := $(BIN_NAME)launcher
launcher-app : INFO_PLIST = $(BUILD_DIR)/launcher-info.plist
launcher-app : build-dir ui-assets launcher-info-plist
	@echo "Creating Launcher App..."
	@mkdir -p $(BUILD_DIR)/$(APP_NAME).app/Contents/{MacOS,Resources}
	@echo "Running 'MAKE' for Launcher Binary..."
	@make -C $(BUILD_PATH) launcher-bin
	@echo "Moving Launcher Binary into Place..."
	@mv $(BUILD_DIR)/$(BIN_NAME).bin $(BUILD_DIR)/$(APP_NAME).app/Contents/Resources/$(BIN_NAME)
	@echo "Copying App Icon into place..."
	@-cp $(BUILD_DIR)/$(ASSETS_BUNDLE_FILENAME)/Contents/Resources/AppIcon.icns \
		$(BUILD_DIR)/$(APP_NAME).app/Contents/Resources/ 2> /dev/null
	@echo "Moving Launcher App Info.plist into place..."
	@mv $(INFO_PLIST) $(BUILD_DIR)/$(APP_NAME).app/Contents/Info.plist
	@if [ $(CODESIGN_BUILD) = true ]; then \
		echo "Signing Launcher App..."; \
		codesign -s $(CODESIGN_ID) --force $(BUILD_DIR)/$(APP_NAME).app; \
	fi


.PHONY : launcher-app-debug
launcher-app-debug : APP_NAME := $(BIN_NAME)launcher
launcher-app-debug : BIN_NAME := $(BIN_NAME)launcher
launcher-app-debug : INFO_PLIST = $(BUILD_DIR)/launcher-info.plist
launcher-app-debug : build-dir ui-assets launcher-info-plist
	@echo "Creating Launcher App with Debug Options..."
	@mkdir -p $(BUILD_DIR)/$(APP_NAME).app/Contents/{MacOS,Resources}
	@echo "Running 'MAKE' for Launcher Application with Debug Options..."
	@make -C $(BUILD_PATH) launcher-bin-debug
	@echo "Moving Launcher Binary into Place..."
	@mv $(BUILD_DIR)/$(BIN_NAME).bin $(BUILD_DIR)/$(APP_NAME).app/Contents/Resources/$(BIN_NAME)
	@echo "Copying App Icon into place..."
	@-cp $(BUILD_DIR)/$(ASSETS_BUNDLE_FILENAME)/Contents/Resources/AppIcon.icns \
		$(BUILD_DIR)/$(APP_NAME).app/Contents/Resources/ 2> /dev/null
	@echo "Moving Launcher App Info.plist into place..."
	@mv $(INFO_PLIST) $(BUILD_DIR)/$(APP_NAME).app/Contents/Info.plist
	@if [ $(CODESIGN_BUILD) = true ]; then \
		echo "Signing Launcher App..."; \
		codesign -s $(CODESIGN_ID) --force $(BUILD_DIR)/$(APP_NAME).app; \
	fi

.PHONY : app
app : purge build-dir ui-assets defaults-plist entitlements-plist
	@echo "Creating App..."
	@make -C $(BUILD_PATH) main-app
	@if [ ! -d $(BUILD_DIR)/$(APP_NAME).app ]; then \
			echo "Error: Application was not created"; \
			exit 1; \
	fi
	@if [ $(BUILD_LAUNCHER) = true ]; then \
		make -C $(BUILD_PATH) launcher-app; \
		if [ ! -d $(BUILD_DIR)/$(BIN_NAME)launcher.app ]; then \
			echo "Error: Launcher Application was not created"; \
			exit 1; \
		fi; \
		echo "Creating Launcher Subdirectories..." ; \
		mkdir -p $(BUILD_DIR)/$(APP_NAME).app/Contents/Library/LoginItems/; \
		echo "Moving Launcher Application into place..."; \
		mv $(BUILD_DIR)/$(BIN_NAME)launcher.app $(BUILD_DIR)/$(APP_NAME).app/Contents/Library/LoginItems/; \
	fi
	@echo "Moving Defaults.plist into place..."
	@mv $(DEFAULTS_PLIST) $(BUILD_DIR)/$(APP_NAME).app/Contents/Resources
	@if [ $(ADD_ENTITLEMENTS) = true ]; then \
		echo "Moving Entitlements file into place..."; \
		mv $(ENTITLEMENTS_PLIST) $(BUILD_DIR)/$(APP_NAME).app/Contents/Resources; \
	fi
	@if [ $(CODESIGN_BUILD) = true ]; then \
		echo "Signing App..."; \
		if [ $(ADD_ENTITLEMENTS) = true ]; then \
			codesign --entitlements $(BUILD_DIR)/$(APP_NAME).app/Contents/Resources/$(ENTITLEMENTS_FILENAME) \
					 --options runtime --timestamp --sign $(CODESIGN_ID) --force $(BUILD_DIR)/$(APP_NAME).app 2> /dev/null; \
		else \
			codesign --timestamp --sign $(CODESIGN_ID) --force $(BUILD_DIR)/$(APP_NAME).app 2> /dev/null; \
		fi; \
	fi
	@echo "Copying App into place..."
	@cp -R $(BUILD_DIR)/$(APP_NAME).app $(BUILD_PATH)
	
	
.PHONY : app-debug
app-debug : APP_NAME := $(APP_NAME)" - Debug"
app-debug : purge build-dir ui-assets defaults-plist entitlements-plist
	@echo "Creating App with Debug Options..."
	@make -C $(BUILD_PATH) main-app-debug
	@if [ ! -d $(BUILD_DIR)/$(APP_NAME).app ]; then \
			echo "Error: Application was not created"; \
			exit 1; \
	fi
	@if [ $(BUILD_LAUNCHER) = true ]; then \
		make -C $(BUILD_PATH) launcher-app-debug; \
		if [ ! -d $(BUILD_DIR)/$(BIN_NAME)launcher.app ]; then \
			echo "Error: Launcher Application was not created"; \
			exit 1; \
		fi; \
		echo "Creating Launcher Subdirectories..." ; \
		mkdir -p $(BUILD_DIR)/$(APP_NAME).app/Contents/Library/LoginItems/; \
		echo "Moving Launcher Application into place..."; \
		mv $(BUILD_DIR)/$(BIN_NAME)launcher.app $(BUILD_DIR)/$(APP_NAME).app/Contents/Library/LoginItems/; \
	fi
	@echo "Moving Defaults.plist into place..."
	@mv $(DEFAULTS_PLIST) $(BUILD_DIR)/$(APP_NAME).app/Contents/Resources
	@if [ $(ADD_ENTITLEMENTS) = true ]; then \
		echo "Moving Entitlements file into place..."; \
		mv $(ENTITLEMENTS_PLIST) $(BUILD_DIR)/$(APP_NAME).app/Contents/Resources; \
	fi
	@if [ $(CODESIGN_BUILD) = true ]; then \
		echo "Signing App..."; \
		if [ $(ADD_ENTITLEMENTS) = true ]; then \
			codesign --entitlements $(BUILD_DIR)/$(APP_NAME).app/Contents/Resources/$(ENTITLEMENTS_FILENAME) \
					 --options runtime --timestamp --sign $(CODESIGN_ID) --force $(BUILD_DIR)/$(APP_NAME).app 2> /dev/null; \
		else \
			codesign --timestamp --sign $(CODESIGN_ID) --force $(BUILD_DIR)/$(APP_NAME).app 2> /dev/null; \
		fi; \
	fi
	@echo "Copying App into place..."
	@cp -R $(BUILD_DIR)/$(APP_NAME).app $(BUILD_PATH)
	

.PHONY : run
run: app
	@echo "Running App..."
	@sleep 1
	@$(BUILD_PATH)/$(APP_NAME).app/Contents/MacOS/$(BIN_NAME)
	
	
.PHONY : rerun
rerun:
	@if [ ! -d $(BUILD_PATH)/$(APP_NAME).app ];then \
		echo "App does not exist. Running Make for app..."; \
		make -C $(BUILD_PATH) app; \
	fi
	@echo "Re-running App..."
	@sleep 1
	@$(BUILD_PATH)/$(APP_NAME).app/Contents/MacOS/$(BIN_NAME)
	
	
.PHONY : run-debug
run-debug : APP_NAME := $(APP_NAME)" - Debug"
run-debug: app-debug
	@echo "Running App with Debug Options..."
	@sleep 1
	@$(BUILD_PATH)/$(APP_NAME).app/Contents/MacOS/$(BIN_NAME)
	
	
# Some guidance from https://stackoverflow.com/questions/96882/how-do-i-create-a-nice-looking-dmg-for-mac-os-x-using-command-line-tools
.PHONY : installer
installer: app
	@echo "Creating Installer..."
	@if [ -f $(BUILD_PATH)/$(INSTALLER_NAME).dmg ]; then \
		echo "Removing Old Installer"; \
		rm -rf $(BUILD_PATH)/$(INSTALLER_NAME).dmg; \
	fi
	@echo "Copying Installer Template..."
	@hdiutil convert $(INSTALLER_TEMPLATE) -format UDSP -o $(BUILD_DIR)/$(INSTALLER_NAME).sparseimage &> /dev/null
	@echo "Mounting Installer Template..."
	@mkdir $(MOUNTPATH)
	@hdiutil attach -nobrowse -mountpoint $(MOUNTPATH) $(BUILD_DIR)/$(INSTALLER_NAME).sparseimage &> /dev/null
	@echo "Preparing Installer Image..."
	@touch $(MOUNTPATH)/.metadata_never_index
	@echo "Setting Installer Volume Icon..."
	@-cp $(BUILD_PATH)/$(APP_NAME).app/Contents/Resources/AppIcon.icns $(MOUNTPATH)/.VolumeIcon.icns 2> /dev/null
	@-SetFile -c icnC $(MOUNTPATH)/.VolumeIcon.icns &> /dev/null
	@SetFile -a C $(MOUNTPATH)
	@echo "Setting Installer Background Image..."
	@cp $(INSTALLER_BACKGROUND) $(MOUNTPATH)/.background/background.png
	@echo "Copying App into place..."
	@cp -R $(BUILD_PATH)/$(APP_NAME).app/Contents $(MOUNTPATH)/"Application Template/Contents"
	-@bless --folder $(MOUNTPATH) --openfolder $(MOUNTPATH)
	@echo "Setting Application Name..."
	@$(BUILD_PATH)/Scripts/finderrename.sh $(MOUNTPATH)/"Application Template" $(APP_NAME).app
	@echo "Setting Installer Name..."
	@diskutil renameVolume $(MOUNTPATH) $(INSTALLER_NAME) &> /dev/null
	@echo "Removing unnecessary system files..."
	@if [ -d $(MOUNTPATH)/.fseventsd ]; then \
		echo "Removing .fseventsd..."; \
		rm -rf $(MOUNTPATH)/.fseventsd; \
	fi
	@if [ -d $(MOUNTPATH)/.Trashes ]; then \
		echo "Removing .Trashes..."; \
		rm -rf $(MOUNTPATH)/.Trashes; \
	fi
	@hdiutil eject $(MOUNTPATH) &> /dev/null
	@echo "Compressing Installer DMG..."
	@hdiutil convert $(BUILD_DIR)/$(INSTALLER_NAME).sparseimage -format UDZO -imagekey zlib-level=9 \
		-o $(BUILD_PATH)/$(INSTALLER_NAME).dmg &> /dev/null
	@if [ $(CODESIGN_BUILD) = true ]; then \
		echo "Signing Installer..."; \
		codesign -s $(CODESIGN_ID) --force $(BUILD_PATH)/$(INSTALLER_NAME).dmg; \
	fi
		

.PHONY : recovery-installer
recovery-installer: app
	@echo "Creating Recovery Mode Installer..."


.PHONY : clean
clean :
	@echo "Cleaning up Project Files..."
	@rm -rf $(BUILD_DIR)
	@make -C $(ASSETS_DIR) clean
	@make -C $(MAIN_SRC_DIR) clean
	@make -C $(LAUNCHER_SRC_DIR) clean
	

.PHONY : purge
purge:
	@echo "Purging Project Files..."
	@hdiutil eject $(MOUNTPATH) &> /dev/null || true
	@rm -rf *.bin
	@rm -rf *.app
	@rm -rf $(BUILD_DIR)
	@make -C $(ASSETS_DIR) purge
	@make -C $(MAIN_SRC_DIR) purge
	@make -C $(LAUNCHER_SRC_DIR) purge
