//
//  ViewController.swift
//  Virtual Extended Keyboard
//
//  Created by Chi Kim on 11/12/18.
//  Copyright © 2018 Chi Kim. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    var down = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        func myCGEventCallback(proxy : CGEventTapProxy, type : CGEventType, event : CGEvent, refcon : UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
            let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
            if event.flags.contains(.maskSecondaryFn) {
                if Int(keyCode) == 49 {
                    if event.type == .keyDown {
                        var location = NSPointToCGPoint(NSEvent.mouseLocation)
                        location.y = NSScreen.main!.frame.size.height-location.y
                        print(location)
                        print(event.location)
                        let mouse = Mouse.shared
                        if !mouse.marked {
                            mouse.mark()
                        } else {
                            mouse.drag()
                        }
                    }
                    return nil
                }
                
                let map = [50:53, 18:122, 19:120, 20:99, 21:118, 12:96, 13:97, 14:98, 15:100, 0:101, 1:109, 2:103, 3:111, 6:106, 7:64, 8:79, 9:80, 38:83, 40:84, 37:85, 32:86, 34:87, 31:88, 26:89, 28:91, 25:92, 46:82, 43:67, 44:75, 41:81, 27:78, 24:69, 47:65, 36:76, 39:71]
                let functionKeys = [122, 120, 99, 118, 96, 97, 98, 100, 101, 109, 103, 111, 106, 64, 79, 80]
                // f13:105, f14:107, f15:113
                var swap = keyCode
                if let findSwap = map[Int(keyCode)] {
                    swap = Int64(findSwap)
                }
                if swap != keyCode {
                    debugPrint("Swapping \(keyCode) with \(swap)")
                    event.setIntegerValueField(.keyboardEventKeycode, value: swap)
                    if !functionKeys.contains(Int(swap)) {
                        event.flags.remove(.maskSecondaryFn)
                    }
                }
                
            }
            if event.type == .keyDown {
                Accessibility.speak("\(keyCode)")
                debugPrint(keyCode)
            }
            return Unmanaged.passRetained(event)
        }
        
        let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue) | (1 << CGEventType.flagsChanged.rawValue)
        guard let eventTap = CGEvent.tapCreate(tap: .cgSessionEventTap, place: .headInsertEventTap, options: .defaultTap, eventsOfInterest: CGEventMask(eventMask), callback: myCGEventCallback, userInfo: nil) else {
            debugPrint("Failed to create event tap")
            exit(1)
        }
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, CFRunLoopMode.commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
        //CFRunLoopRun()
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
}

