//
//  RssParser.swift
//  RSS Reader
//
//  Created by Sergey Bizunov on 11/18/19.
//  Copyright © 2019 Sergey Bizunov. All rights reserved.
//

import Foundation

protocol RssParserDelegate: class {
    func updateNews(_ news: String)     // TODO: Add Struct Objects
    func parserError()                  // TODO: Implement Error Handling
}

class RssParser {

    weak var delegate: RssParserDelegate?

    private var urlPath: String

    init(urlPath: String) {
        self.urlPath = urlPath
    }

    func parse() {
        sleep(1)
        delegate?.updateNews("Parsed complete!")
        sleep(1)
        delegate?.parserError()
    }
}
