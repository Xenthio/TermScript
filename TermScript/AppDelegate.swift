//
//  AppDelegate.swift
//  TermScript
//
//  Created by Ethan Cardwell on 19/2/20.
//  Copyright © 2020 Ethan Cardwell. All rights reserved.
//

var Developer = 1

import Foundation
import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSTextViewDelegate {

    @IBOutlet weak var window: NSWindow!
    
    @IBOutlet var TextView: NSTextView!
    var timer : Timer?
    var allText="echo bash poop pee"
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func runCommand(cmd : String, args : String){

        // Create a Task instance
        let task = Process()

        // Set the task parameters
        task.launchPath = cmd
        task.arguments = args.components(separatedBy: " ")
         
        // Create a Pipe and make the task
        // put all the output there
        let pipe = Pipe()
        task.standardOutput = pipe

        // Launch the task
        task.launch()
         
        // Get the data
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)

        print(output!)
    }
    var inDarkMode: Bool {
        let mode = UserDefaults.standard.string(forKey: "AppleInterfaceStyle")
        return mode == "Dark"
    }
    
    struct Colours { // colour scheme for commands
        static var normal = NSColor.textColor
        static var commands = NSColor.systemPink
        static var executables = NSColor.systemPink
        static var strings = NSColor.systemOrange
        static var logic = NSColor.magenta
        static var darkvariables = NSColor.cyan
        static var litevariables = NSColor.blue
        static var comments = NSColor.systemGray
    }
    
    struct Fonts {
        static var normal = NSFont(name: "Courier New", size: 12)
        static var commands = NSFont(name: "Courier New Bold", size: 12)
        static var executables = NSFont(name: "Courier New Bold", size: 12)
        static var strings = NSFont(name: "Courier New", size: 12)
        static var logic = NSFont(name: "Courier New Bold", size: 12)
        static var variables = NSFont(name: "Courier New", size: 12)
        static var comments = NSFont(name: "Courier New", size: 12)
    }
    
    let fileManager = FileManager.default
    
    let binFolder = NSURL(fileURLWithPath: "/bin/", isDirectory: true)
    var commands = ["echo","bash","ls","let","if"]
    var executables = [""]
    var logic = ["[","]","-eq","!=","==","(",")"]
    var vars = ["="]

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
//        do {
//            let Document = try NSDocument(type: "Text")
//        } catch {
//            print("Error")
//        }
        do {
            executables = try fileManager.contentsOfDirectory(atPath: "/bin/")
            
        } catch {
            print("Bitch yo dun hav a bin folder how u even boot up?")
        }
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(self.themeChangedNotification(notification:)), name: NSNotification.Name(rawValue: "AppleInterfaceThemeChangedNotification"), object: nil)
        TextView.delegate = self;
        TextView.toggleAutomaticQuoteSubstitution(Any?.self)
        if TextView.string != "" {
            update()
        }
        
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
   
    var updater = false
    

    
    @objc func themeChangedNotification(notification: Notification) {
        //Theme Changed
    }
    
    func textDidChange(_ notification: Notification) {
        guard let TextView = notification.object as? NSTextView else { return }
        if TextView.string != "" {
            update()
        }
    }
    
    func update() {
        TextView.string = TextView.string.replacingOccurrences(of: "\t", with: "    ")
        var text = TextView.string
        let lines = TextView.string.components(separatedBy: "\n")
        for line in lines {
            let words = line.components(separatedBy: " ")
            if line.hasPrefix("#") {
                let a = Colours.comments
                let b = Fonts.comments
                text = changeText(line, text: text, scheme: a, font: b!)
            } else {
                

                
            for word in words {
                print("Current word is: " + word)
                print(" ")
                print("Fake is: " + text)
                print("Fake count is: " + String(text.count))
                print(" ")
                print("Real is: " + TextView.string)
                print("Real count is: " + String(TextView.string.count))
                if logic.contains(where: word.contains) {
                    let a = Colours.logic
                    let b = Fonts.logic
                    text = changeText(word, text: text, scheme: a, font: b!)
                } else if commands.contains(where: word.contains) {
                    let a = Colours.commands
                    let b = Fonts.commands
                    text = changeText(word, text: text, scheme: a, font: b!)
                } else if executables.contains(where: word.contains) {
                    let a = Colours.executables
                    let b = Fonts.executables
                    text = changeText(word, text: text, scheme: a, font: b!)
                } else if logic.contains(where: word.contains) {
                    let a = Colours.logic
                    let b = Fonts.logic
                    text = changeText(word, text: text, scheme: a, font: b!)
                } else if vars.contains(where: word.contains) {
                    var a = Colours.normal
                    if inDarkMode {
                        a = Colours.darkvariables
                    } else {
                        a = Colours.litevariables
                    }
                    let b = Fonts.variables
                    text = changeText(word, text: text, scheme: a, font: b!)
                } else if word.hasPrefix("$") {
                    var a = Colours.normal
                    if inDarkMode {
                        a = Colours.darkvariables
                    } else {
                        a = Colours.litevariables
                    }
                    let b = Fonts.variables
                    text = changeText(word, text: text, scheme: a, font: b!)
                
                    
                } else if word.contains("\"") {
                    if let r1 = text.range(of: "\""),
                        let r2 = text.range(of: "\"", range: r1.upperBound..<text.endIndex) {

                        let sbq = text.substring(with: r1.upperBound..<r2.lowerBound)
                        let swq = "\"" + sbq + "\""
                        //stringBetweenQuotes
                        let a = text.range(of: swq)!
                        let b = NSRange(a, in: text)
                        TextView.setTextColor(Colours.strings, range: b)
                        TextView.setFont(Fonts.strings!, range: b)
                        
                        var c = ""
                        for _ in swq {
                            c = "z" + c
                        }
                        text.replaceSubrange(a, with: c)
                        
                    }
                    
                } else if word.contains("'") {
                    if let r1 = text.range(of: "'"),
                        let r2 = text.range(of: "'", range: r1.upperBound..<text.endIndex) {

                        let sbq = text.substring(with: r1.upperBound..<r2.lowerBound)
                        let swq = "'" + sbq + "'"
                        //stringBetweenQuotes
                        let a = text.range(of: swq)!
                        let b = NSRange(a, in: text)
                        TextView.setTextColor(Colours.strings, range: b)
                        TextView.setFont(Fonts.strings!, range: b)
                        
                        var c = ""
                        for _ in swq {
                            c = "z" + c
                        }
                        text.replaceSubrange(a, with: c)
                        
                    }
                
                } else if word != "" {
                    let o = text.range(of: word)
                    if o == nil {
                        break
                    }
                    let a = o!
                    let b = NSRange(a, in: text)
                    TextView.setTextColor(Colours.normal, range: b)
                    TextView.setFont(Fonts.normal!, range: b)
                }
            }
            }
        }
    }
    
    func changeText(_ word: String, text: String, scheme: NSColor, font: NSFont) -> String {
        do {
            let o = text.range(of: word)
            if o == nil {
                return text
            }
            let a = o!
            let b = NSRange(a, in: text)


            TextView.setTextColor(scheme, range: b)
            TextView.setFont(font, range: b)
            var c = ""
            for _ in word {
                c = "z" + c
            }
            var out = text
            out.replaceSubrange(a, with: c)
            return out
        } catch {
            return text
        }
    }
    
    var currentDoc = "poop"
    @IBOutlet var view: NSView!
    
    @IBAction func Save(_ sender: Any) {
        
        if currentDoc == "poop" {
            let boomer = saveDoc()
            if boomer != nil {
                do {
                    let fileUrl = boomer!.path
                    let input = TextView.string
                    try input.write(to: URL.init(fileURLWithPath: fileUrl), atomically: true, encoding: .utf8)
                    
                    runCommand(cmd: "/bin/chmod", args: "+x " + fileUrl)
                    
                    currentDoc = fileUrl

                    window.title = "TermScript - " + currentDoc.components(separatedBy: "/").last!
                    
                    
                } catch {
                    print(error)
                }
            }
        } else {
            
            let fileUrl = currentDoc
            let input = TextView.string
            do {
                try input.write(to: URL.init(fileURLWithPath: fileUrl), atomically: true, encoding: .utf8)
                runCommand(cmd: "/bin/chmod", args: "+x " + fileUrl)
            } catch {
                print(error)
            }
        }
        
    }
    @IBAction func Open(_ sender: Any) {
        
        let boomer = openDoc()
        if boomer != nil {
            do {
                currentDoc = boomer!.path
                let ok = try String(contentsOf: boomer!)
                TextView.string = ok
                window.title = "TermScript - " + currentDoc.components(separatedBy: "/").last!
                update()
                
            } catch {
                print("error")
            }
        }
        
        
    }
    
    func saveDoc() -> URL? {
        let ok=NSSavePanel()
        ok.runModal()
        return ok.url
    }
    
    func openDoc() -> URL? {
        let ok=NSOpenPanel()
        ok.runModal()
        return ok.url
    }
    
    @IBAction func DebugPrint(_ sender: Any) {
        print(TextView.string.components(separatedBy: "\""))
    }
    
    func ConPrint(_ ToPrint: Any) {
        if Developer == 1 {
            print(ToPrint)
        }
    }
    
}

