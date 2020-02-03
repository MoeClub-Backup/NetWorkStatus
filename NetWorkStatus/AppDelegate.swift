//
//  AppDelegate.swift
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem:NSStatusItem
    let statusItemView:StatusItemView
    let menu:NSMenu
    let autoLaunchMenu:NSMenuItem
    
    override init() {
        statusItem = NSStatusBar.system.statusItem(withLength: 72)
        
        menu = NSMenu()
        autoLaunchMenu = NSMenuItem()
        autoLaunchMenu.title = NSLocalizedString("Start at login", comment: "") 
        autoLaunchMenu.state = NSControl.StateValue(rawValue: AutoLaunchHelper.isLaunchWhenLogin() ? 1 : 0)
        autoLaunchMenu.action = #selector(menuItemAutoLaunchClick)
        menu.addItem(autoLaunchMenu)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: NSLocalizedString("Quit", comment: ""), action: #selector(menuItemQuitClick), keyEquivalent: "q")
        
        statusItemView = StatusItemView(statusItem: statusItem, menu: menu)
        statusItem.view = statusItemView
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
         NetWorkMonitor(statusItemView: statusItemView).start()
    }
}

//action
extension AppDelegate {
    @objc func menuItemQuitClick() {
        NSApp.terminate(nil)
    }
    
    @objc func menuItemAutoLaunchClick() {
        AutoLaunchHelper.toggleLaunchWhenLogin()
        autoLaunchMenu.state = NSControl.StateValue(rawValue: AutoLaunchHelper.isLaunchWhenLogin() ? 1 : 0)
    }
}
