UIToolbox
=========
 A blank layout for building a new app using Make rather than Xcode, wrapping shell script with nice UI elements

 This repository will take a directory structure as below and output a macOS application or installer when running the included makefile. Note that this is not the best way of doing things, but it works as a hacky way to build an app outside of the Xcode ecosystem

~~~
 Project Directory Structure
 |
 +-> Makefile (For Entire Project)
 +-> Assets
 |   |
 |   +-> Installer Template.dmg
 |   +-> Makefile (For Asset Bundle)
 |   |
 |   +-> UI Assets
 |   |   |
 |   |   +-> [ All UI assets used in the app as 1024x1024 PNGs]
 |   |   +-> Icons
 |   |   |   |
 |   |   |   +-> App Icon
 |   |   |   |   |
 |   |   |   |   +-> [ App Icon, as a 1024x1024 PNG ]
 |   |   |   +-> Status Bar Icons
 |   |   |   |
 |   |   |   +-> [ All icons used in the Status Bar as 1024x1024 PNGs ]
 |   |   +-> Installer Background
 |   |       |
 |   |       +-> Installer Background.png, an 828x512 PNG
 |   +-> UI ELement Mockups
 |       |
 |       +-> [ Supporting files used to created the 1024x1024 PNGs ]
 +-> Scripts
 |   |
 |   +-> createicns.sh
 |   +-> createplist.sh
 |   +-> createuiassets.sh
 |   +-> finderrename.scpt
 |   +-> finderrename.sh
 |   +-> App Scripts
 |       |
 |       +-> main
 |       +-> [ Additional scripts as required ]
 +-> Source
     |
     +-> Launcher
     |   |
     |   +-> Makefile (For Launcher Application)
     |   +-> lib
     |   |   |
     |   |   +-> [ Launcher Application Supporting Libraries ]
     |   +-> src
     |       |
     |       +-> [ Launcher Application Source Files ]
     +-> Main
         |
         +-> Makefile (For Main Application)
         +-> lib
         |   |
         |   +-> [ Main Application Supporting Libraries ]
         +-> src
             |
             +-> [ Main Application Source Files ]


 Installer Template.dmg
 |
 +-> .DS_Store (Required)
 +-> .background
 |   |
 |   +-> background.png, an 828x512 PNG
 +-> Application Template
 |   |
 |   +-> [ Empty ]
 +-> Applications (An alias to /Applications)


 App Structure
 |
 +-> Contents
     |
     +-> Info.plist
     +-> _CodeSignature
      |   |
      |   +-> [ Files as required for a signed application ]
     +-> Library (Present when a helper launch-at-login application is required)
     |   |
     |   +-> LoginItems
     |       |
     |       +-> Contents
     |           |
     |           +-> Info.plist
     |           +-> MacOS
     |             |   |
     |           |   +-> [ Compiled launcher utility binary ]
     |           +-> Resources
     |               |
     |               +-> AppIcon.icns
     +-> MacOS
     |   |
     |   +-> [ Compiled Toolbox Binary ]
     |   +-> main
     |   +-> [additional scripts as required].sh
     +-> Resources
          |
          +-> AppIcon.icns
          +-> Assets.bundle
          |   |
         |   +-> _CodeSignature
          |   +-> [ Files as required for a signed bundle ]
          |   +-> Contents
          |         |
          |         +-> Info.plist
          |         +-> Resources
          |             |
          |             +-> AppIcon.icns
          |             +-> [ All other image and resource files required by the app ]
          +-> [ Additional Scripts, as required ]
          +-> Defaults.plist (Contains application default settings)
          +-> App_Name.entitlements (Contains application entitlements, if used)
~~~
