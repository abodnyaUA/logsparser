//
//  StringExtensions.swift
//  LogsParser
//
//  Created by Aleksey Bodnya on 8/21/17.
//  Copyright © 2017 Aleksey Bodnya. All rights reserved.
//

import Foundation

extension String {

    var linesCount: Int {
        var count: Int = 1
        for character in self.characters {
            if character == "\n" {
                count += 1
            }
        }
        return count
    }
}
