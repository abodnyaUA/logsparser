//
//  Document.swift
//  LogsParser
//
//  Created by Aleksey Bodnya on 8/18/17.
//  Copyright © 2017 Aleksey Bodnya. All rights reserved.
//

import Cocoa

class Document: NSDocument {

    var messages = [Message]()

    override class func autosavesInPlace() -> Bool {
        return true
    }

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: "Document Window Controller") as! NSWindowController
        let viewController = windowController.contentViewController as? ViewController
        viewController?.representedObject = self
        self.addWindowController(windowController)
    }

    override func data(ofType typeName: String) throws -> Data {
        // Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
        // You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }

    override func windowControllerDidLoadNib(_ windowController: NSWindowController) {
        super.windowControllerDidLoadNib(windowController)
    }

    override func read(from data: Data, ofType typeName: String) throws {
        // Insert code here to read your document from the given data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning false.
        // You can also choose to override readFromFileWrapper:ofType:error: or readFromURL:ofType:error: instead.
        // If you override either of these, you should also override -isEntireFileLoaded to return false if the contents are lazily loaded.
        self.messages.removeAll()
        let logSwiftString = String(data: data, encoding: .utf8)
        guard logSwiftString != nil else {
            throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }
        let logString = logSwiftString! as NSString

        let pattern = "\\d\\d\\d\\d\\-\\d\\d\\-\\d\\d \\d\\d\\:\\d\\d\\:\\d\\d\\.\\d\\d\\d"
        let regexp = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options(rawValue: 0))

        var startIndex = NSNotFound
        regexp.enumerateMatches(in: logSwiftString!, options: .init(rawValue: 0), range: NSMakeRange(0, logString.length)) { (result, flags, stop) in
            guard result != nil else {
                return
            }
            let currentIndex = result!.range.location
            if startIndex != NSNotFound {
                let previousEndLine = logString.range(of: "\n", options: .backwards, range: NSMakeRange(startIndex, currentIndex - startIndex))
                let endIndex = previousEndLine.location
                let substring = logString.substring(with: NSMakeRange(startIndex, endIndex - startIndex)) as NSString
                if self.addMessage(logString: substring) {
                    startIndex = currentIndex
                }
            } else {
                startIndex = currentIndex
            }
        }
        if startIndex == NSNotFound {
            startIndex = 0
        }
        let substring = logString.substring(with: NSMakeRange(startIndex, logString.length - startIndex)) as NSString
        self.addMessage(logString: substring)
    }

    @discardableResult func addMessage(logString: NSString) -> Bool {
        guard logString.length > 23 else {
            return false
        }
        let dateString = logString.substring(to: 23)
        let messageRange = logString.range(of: ": ")
        guard messageRange.location != NSNotFound else {
            return false
        }
        var method = logString.substring(with: NSMakeRange(24, messageRange.location - 24))
        var level = Level.common
        if let range = method.range(of: "[Error]"), range.lowerBound == method.startIndex {
            level = .error
            method = method.substring(from: method.index(method.startIndex, offsetBy: 8))
        }
        let message = logString.substring(from: NSMaxRange(messageRange)).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let messageObject = Message()
        messageObject.method = method
        messageObject.message = message
        messageObject.dateString = dateString
        messageObject.level = level
        self.messages.append(messageObject)
        return true
    }
}

