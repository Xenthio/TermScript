//
//  DialogMessage.swift
//  TermScript
//
//  Created by Ethan Cardwell on 20/2/20.
//  Copyright © 2020 Ethan Cardwell. All rights reserved.
//

import Cocoa

class Dialog: NSObject, NSWindowDelegate {
    
    let xibfile = NSNib.init(nibNamed: NSNib.Name("DialogMessage"), bundle: .main)
    let window = NSNib.init(nibNamed: NSNib.Name("DialogMessage"), bundle: .main)!.objectSpecifier!.
    
    func displayDialog(_ message: String, title: String, buttontext: String) {
        dialog.stringValue = message
        window.title = title
        button.stringValue = buttontext
        window.setIsVisible(true)
    }
    
}
