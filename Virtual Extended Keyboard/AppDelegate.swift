//
//  AppDelegate.swift
//  Virtual Extended Keyboard
//
//  Created by Chi Kim on 11/12/18.
//  Copyright © 2018 Chi Kim. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	
	let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
	
	func checkAccess(ask:Bool) -> Bool {
		let prompt = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString
		let options = [prompt: ask]
		return AXIsProcessTrustedWithOptions(options as CFDictionary?)
	}
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		if !checkAccess(ask:true) {
			NSApplication.shared.terminate(self)
		}
		
		let fileManager = FileManager.default
		let home = fileManager.homeDirectoryForCurrentUser
		let launchFolder = home.appendingPathComponent("Library/LaunchAgents")
		if !fileManager.fileExists(atPath: launchFolder.path) {
			try! fileManager.createDirectory(at: launchFolder, withIntermediateDirectories: false, attributes: nil)
		}
		let launchPath = "Library/LaunchAgents/com.chikim.Virtual-Extended-Keyboard.plist"
		let launchFile = home.appendingPathComponent(launchPath)
		let defaults = UserDefaults.standard
		if !defaults.bool(forKey: "launchedBefore") && !fileManager.fileExists(atPath: launchFile.path) {
			let bundle = Bundle.main
			let bundlePath = bundle.path(forResource: "com.chikim.Virtual-Extended-Keyboard", ofType: "plist")
			try! fileManager.copyItem(at: URL(fileURLWithPath: bundlePath!), to: launchFile)
			defaults.set(true, forKey: "launchedBefore")
		}
		
		let menu = NSMenu()
		let menuItem = NSMenuItem(title: "Launch on Login", action: #selector(AppDelegate.toggleLaunch(_:)), keyEquivalent: "")
		if fileManager.fileExists(atPath: launchFile.path) {
			menuItem.state = .on
		}
		
		menu.addItem(menuItem)
		menu.addItem(withTitle: "Quit", action: #selector(AppDelegate.quit(_:)), keyEquivalent: "")
		statusItem.menu = menu
		
		if let button = statusItem.button {
			button.image = NSImage(named: "Virtual-Extended-Keyboard-StatusBar-Icon")
			button.action = #selector(AppDelegate.click(_:))
		}
		NSApplication.shared.windows[1].close()
		NSApplication.shared.hide(self)
		NSApplication.shared.deactivate()
	}
	
	@objc func click(_ sender: Any?) {
		debugPrint("ok")
	}
	
	@objc func quit(_ sender: AnyObject?) {
		NSApplication.shared.terminate(self)
	}
	
	@objc func toggleLaunch(_ sender: AnyObject?) {
		let fileManager = FileManager.default
		let home = fileManager.homeDirectoryForCurrentUser
		let launchPath = "Library/LaunchAgents/com.chikim.Virtual-Extended-Keyboard.plist"
		let launchFile = home.appendingPathComponent(launchPath)
		let menu = statusItem.menu
		let menuItem = menu?.item(withTitle:"Launch on Login")
		if menuItem?.state == .off {
			if !fileManager.fileExists(atPath: launchFile.path) {
				let bundle = Bundle.main
				let bundlePath = bundle.path(forResource: "com.chikim.Virtual-Extended-Keyboard", ofType: "plist")
				try! fileManager.copyItem(at: URL(fileURLWithPath: bundlePath!), to: launchFile)
			}
			menuItem?.state = .on
		} else {
			try!fileManager.removeItem(at: launchFile)
			menuItem?.state = .off
		}
	}
	
	
}

