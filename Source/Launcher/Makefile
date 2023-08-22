# ========================================================================================
# =============================== LAUNCHER APP MAKEFILE ==================================
# ========================================================================================
#
# Helper Makefile to build an application from source, and package into an application
# with a minimal Info.plist. This is used in conjunction with the main project makefile
# and some other supporting files following the following directory structure
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

# Location of desired compiler
CC := /usr/bin/swiftc

# Files to compile
FILETYPES := swift

MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
# make is bad at handling directories with spaces!
BUILD_PATH := $(shell dirname '$(MAKEFILE_PATH)')

BUILD_DIR_NAME := .build
BUILD_DIR := $(BUILD_PATH)/$(BUILD_DIR_NAME)
SCRIPTS_DIR := $(BUILD_PATH)/../../Scripts
SRC_DIR := $(BUILD_PATH)/src
LIB_DIR := $(BUILD_PATH)/lib

ifneq ($(INFO_PLIST),)
LDFLAGS := -Xlinker -sectcreate -Xlinker __TEXT -Xlinker __info_plist -Xlinker $(INFO_PLIST)
endif

SOURCES += $(wildcard $(SRC_DIR)/*.$(FILETYPES))
SOURCES += $(wildcard $(LIB_DIR)/*.$(FILETYPES))

.PHONY : build-dir
build-dir :
	@if [ ! -d $(BUILD_DIR) ]; then \
		echo "Creating Launcher App Build Directory..."; \
		mkdir $(BUILD_DIR); \
	fi


%.x86_64.bin : BIN_NAME = $(shell echo $@ | cut -f 1 -d '.')
%.x86_64.bin : build-dir
	@echo "Making x86 Binary..."
	@$(CC) $(LDFLAGS) $(SOURCES) -target x86_64-apple-macos11 -o $(BUILD_DIR)/$(BIN_NAME).bin


%.x86_64.debug : BIN_NAME = $(shell echo $@ | cut -f 1 -d '.')
%.x86_64.debug : build-dir
	@echo "Making x86 Binary with Debug Options..."
	@$(CC) $(LDFLAGS) $(SOURCES) -target x86_64-apple-macos11 -D DEBUG -o $(BUILD_DIR)/$(BIN_NAME).bin
	
	
%.arm64.bin : BIN_NAME = $(shell echo $@ | cut -f 1 -d '.')
%.arm64.bin : build-dir
	@echo "Making Arm Binary..."
	@$(CC) $(LDFLAGS) $(SOURCES) -target arm64-apple-macos11 -o $(BUILD_DIR)/$(BIN_NAME).bin


%.arm64.debug : BIN_NAME = $(shell echo $@ | cut -f 1 -d '.')
%.arm64.debug : build-dir
	@echo "Making Arm Binary with Debug Options..."
	@$(CC) $(LDFLAGS) $(SOURCES) -target arm64-apple-macos11 -D DEBUG -o $(BUILD_DIR)/$(BIN_NAME).bin


%.universal.bin : BIN_NAME = $(shell echo $@ | cut -f 1 -d '.')
%.universal.bin : build-dir
	@echo "Making Universal Binary..."
	@make -C $(BUILD_PATH) $(BIN_NAME).x86_64.bin INFO_PLIST=$(INFO_PLIST)
	@mv $(BUILD_DIR)/$(BIN_NAME).bin $(BUILD_DIR)/$(BIN_NAME).x86_64
	@make -C $(BUILD_PATH) $(BIN_NAME).arm64.bin INFO_PLIST=$(INFO_PLIST)
	@mv $(BUILD_DIR)/$(BIN_NAME).bin $(BUILD_DIR)/$(BIN_NAME).arm64
	@echo "Combining Binaries with the lipo tool..."
	@lipo -create -output $(BUILD_DIR)/$(BIN_NAME).bin $(BUILD_DIR)/$(BIN_NAME).x86_64 $(BUILD_DIR)/$(BIN_NAME).arm64


%.universal.debug : BIN_NAME = $(shell echo $@ | cut -f 1 -d '.')
%.universal.debug : build-dir
	@echo "Making Universal Binary with Debug Options..."
	@make -C $(BUILD_PATH) $(BIN_NAME).x86_64.debug INFO_PLIST=$(INFO_PLIST)
	@mv $(BUILD_DIR)/$(BIN_NAME).bin $(BUILD_DIR)/$(BIN_NAME).x86_64
	@make -C $(BUILD_PATH) $(BIN_NAME).arm64.debug INFO_PLIST=$(INFO_PLIST)
	@mv $(BUILD_DIR)/$(BIN_NAME).bin $(BUILD_DIR)/$(BIN_NAME).arm64
	@echo "Combining Binaries with the lipo tool..."
	@lipo -create -output $(BUILD_DIR)/$(BIN_NAME).bin $(BUILD_DIR)/$(BIN_NAME).x86_64 $(BUILD_DIR)/$(BIN_NAME).arm64


.PHONY : clean
clean:
	@echo "Cleaning up Launcher App Files..."
	@rm -rf $(BUILD_DIR)
	
	
.PHONY : purge
purge: clean
