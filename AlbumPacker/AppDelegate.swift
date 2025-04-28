//
//  AppDelegate.swift
//  AlbumPacker
//
//  Created by lava on 2025/4/26.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    
    override init() {
        super.init()
        print("init")
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

