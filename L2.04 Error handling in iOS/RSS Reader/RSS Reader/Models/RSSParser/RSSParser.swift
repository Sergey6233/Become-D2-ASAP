//
//  RssParser.swift
//  RSS Reader
//
//  Created by Sergey Bizunov on 11/18/19.
//  Copyright © 2019 Sergey Bizunov. All rights reserved.
//

import Foundation

protocol RSSParserDelegate: class {
    func updatePosts(_ posts: [Post])
    func parserError(_ error: RSSParserError)
}

class RSSParser: NSObject {

    // MARK: - Properties

    weak var delegate: RSSParserDelegate?

    private var parser: XMLParser?

    private var urlPath: String

    private var tempPost: Post?

    private var posts: [Post]?

    // MARK: - Initialization

    init(urlPath: String) {
        self.urlPath = urlPath
    }

    // MARK: - Methods

    func parse() {
        guard let url = URL(string: urlPath) else {
            delegate?.parserError(.invalidUrl)
            return
        }
        parser = XMLParser(contentsOf: url)
        parser?.delegate = self
        parser?.parse()
    }
}

// MARK: - XMLParserDelegate

extension RSSParser: XMLParserDelegate {

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {

    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {

    }


    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {

    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        delegate?.parserError(.nativeXMLParserError(parseError))
    }
}
