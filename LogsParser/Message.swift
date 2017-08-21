//
//  Message.swift
//  LogsParser
//
//  Created by Aleksey Bodnya on 8/18/17.
//  Copyright © 2017 Aleksey Bodnya. All rights reserved.
//

import Cocoa

class Message: NSObject {

    var dateString = String()
    var method = String()
    var message = String() {
        didSet {
            self.linesCount = self.message.linesCount
        }
    }
    var level = Level.common
    fileprivate(set) var linesCount = 0
}

enum Level {

    case common
    case error
}
