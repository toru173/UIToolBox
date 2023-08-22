import AppKit
import Foundation
import SwiftUI

// Helper function to exit with an error message
func exit_error(errorCode : Int32 = 0, errorMessage: String = "") {
    if errorMessage != "" { fputs(errorMessage + "\n", stderr) }
    exit(errorCode)
}

// First try to figure out how the UI Toolbox has been called
switch (CommandLine.arguments[0] as NSString).lastPathComponent {
    case "alert" :
        alert(arguments: CommandLine.arguments)
    case "open" :
        open(arguments: CommandLine.arguments)
    case "save" :
        save(arguments: CommandLine.arguments)
    case "menu" :
        menu(arguments: CommandLine.arguments)
    case _:
        exit_error()
}

func alert(arguments: [String]) {

    let helpText = "Usage: alert \"Message Text\" \"Informative Text\" [ --show-cancel ]"

    var showCancel = false

    if arguments.count < 3 || arguments.count > 4 {
        exit_error(errorCode: 255, errorMessage: helpText)
    }

    if arguments.count == 4 {
        if arguments[3] != "--show-cancel" {
            exit_error(errorCode: 255, errorMessage: helpText)
        } else {
            showCancel = true
        }
    }

    let messageTextString = arguments[1]
    let informativeTextString = arguments[2]

    let alert = NSAlert()
    alert.window.level = .floating
    alert.messageText = messageTextString
    alert.informativeText = informativeTextString
    alert.alertStyle = .informational
    alert.addButton(withTitle: "OK")
    if showCancel { alert.addButton(withTitle: "Cancel") }
    let response = alert.runModal().rawValue
    if response == 1000 { exit_error(errorCode: 0) }
    else { exit_error(errorCode: 1) }
}


func save(arguments: [String]) {
    
    let helpText = "Usage: save [ extension ]"
    
    var allowedExtension : String = ""

    if arguments.count > 2  {
        exit_error(errorCode: 255, errorMessage: helpText)
    }
    
    if arguments.count == 2 {
        allowedExtension = arguments[1]
    }
    
    let savePanel = NSSavePanel()
    savePanel.isFloatingPanel = true
    savePanel.isExtensionHidden = false
    savePanel.canCreateDirectories = true
    
    savePanel.title = "Save File Location"
    if allowedExtension != "" { savePanel.allowedFileTypes = [allowedExtension] }
    savePanel.allowsOtherFileTypes = true
    
    let response = savePanel.runModal()
    if savePanel.url != nil {
        fputs(savePanel.url!.path + "\n", stdout)
    }
    if response == .OK { exit_error(errorCode: 0) }
    else { exit_error(errorCode: 1) }
}


func open(arguments: [String]) {
    
    let helpText = "Usage: open [ --allow-multiple ]"
    
    var allowMultiple = false

    if arguments.count > 2  {
        exit_error(errorCode: 255, errorMessage: helpText)
    }
        
    if arguments.count == 2 {
        if arguments[1] != "--allow-multiple" {
        exit_error(errorCode: 255, errorMessage: helpText)
        } else {
            allowMultiple = true
        }
    }
    
    let openPanel = NSOpenPanel()
    openPanel.canChooseFiles = true
    openPanel.canChooseDirectories = true
    openPanel.isFloatingPanel = true
    openPanel.allowsOtherFileTypes = true

    openPanel.title = "Open File Location"
    openPanel.allowsMultipleSelection = allowMultiple

    let response = openPanel.runModal()
    for url in openPanel.urls {
        fputs(url.path + "\n", stdout)
    }
    if response == .OK { exit_error(errorCode: 0) }
    else { exit_error(errorCode: 1) }
}

func menu(arguments: [String]) {
    
    exit_error(errorMessage: "Not Implemented")
    
    class AppDelegate: NSObject, NSApplicationDelegate {

        func applicationDidFinishLaunching(_ notification: Notification) {
            let appMenu = NSMenuItem()
            appMenu.submenu = NSMenu()
            appMenu.submenu?.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
            let mainMenu = NSMenu(title: "Application Title")
            mainMenu.addItem(appMenu)
            NSApplication.shared.mainMenu = mainMenu
        }
    }
    
    let app = NSApplication.shared
    let delegate = AppDelegate()
    app.delegate = delegate
    app.run()
}
