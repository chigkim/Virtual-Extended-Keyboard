//
//  Mouse.swift
//  Virtual Extended Keyboard
//
//  Created by Chi Kim on 2/26/20.
//  Copyright © 2020 Chi Kim. All rights reserved.
//

import Foundation

class Mouse {
	
	static let shared = Mouse()
	var p = CGPoint()
	var marked = false

	var  voCursor:CGPoint {
		get {
		let bundle = Bundle.main
		let script = bundle.url(forResource: "VOCursor", withExtension: "scpt")
		debugPrint(script)
		var error:NSDictionary?
		if let scriptObject = NSAppleScript(contentsOf: script!, error: &error) {
			var outputError:NSDictionary?
			if let output = scriptObject.executeAndReturnError(&outputError).stringValue {
				print("Output: \(output)")
				let bounds = output.split(separator: ",")
				let width = Int(bounds[2])!-Int(bounds[0])!
				let height = Int(bounds[3])!-Int(bounds[1])!
				let rect = CGRect(x: Int(bounds[0])!, y: Int(bounds[1])!, width:width, height: height)
				let point = CGPoint(x: rect.midX, y: rect.midY)
				return point
			} else {
				debugPrint("Output Error: \(outputError)")
			}
		} else {
			debugPrint(error)
		}
		return CGPoint()
	}
	}

	func mark() {
		p = voCursor
		let down = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: p, mouseButton: .left)
		down?.post(tap: .cghidEventTap)
		marked = true
		print("Mark: \(p)")
	}

	func drag() {
		let p2 = voCursor
		let drag = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDragged, mouseCursorPosition: p2, mouseButton: .left)
		drag?.post(tap: .cghidEventTap)
		usleep(30*1000)
		let up = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: p2, mouseButton: .left)
		up?.post(tap: .cghidEventTap)
		marked = false
		print("Drag from: \(p) to \(p2)")
	}
}
