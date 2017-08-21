//
//  AppDelegate.swift
//  LogsParser
//
//  Created by Aleksey Bodnya on 8/18/17.
//  Copyright © 2017 Aleksey Bodnya. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var displayOnlyMarkedMenuItem: NSMenuItem!

    class var shared: AppDelegate {
        return NSApp.delegate as! AppDelegate
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        MethodSwizzle.swizzle()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

