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
    func updateProgress(_ progress: Int, isUpdateToMaxProgress: Bool)
    func parserError(_ error: RSSParserError)
}

class RSSParser: NSObject {

    private struct Constants {
        static let minProgress = 0
        static let maxProgress = 100
    }

    private enum XMLParam: String {
        case item
        case link
        case mediaContent = "media:content"
        case pubDate
        case title
        case url
    }

    // MARK: - Properties

    weak var delegate: RSSParserDelegate?

    private var parser: XMLParser?

    private var urlPath: String

    private var tempElement: String?

    private var tempPost: Post?

    private var posts: [Post]?

    @objc dynamic var kvoPosts: [Post] = []

    private var progress: Int = 0 {
        didSet {
            if oldValue != progress {
                let isMaxProgress = progress == Constants.maxProgress ? true : false
                delegate?.updateProgress(progress, isUpdateToMaxProgress: isMaxProgress)
            }
        }
    }

    private var totalLines = 0

    private var postsTitles: [String] {
        guard let posts = posts else {
            return []
        }
        return posts.compactMap { $0.title }
    }

    // MARK: - Initialization

    init(urlPath: String) {
        self.urlPath = urlPath
        posts = []
    }

    // MARK: - Base Logic

    func parse() {
        guard let url = URL(string: urlPath), let xmlParser = XMLParser(contentsOf: url) else {
            delegate?.parserError(.invalidUrl)
            return
        }

        // Lines in the XML body
        if let data = try? String(contentsOf: url, encoding: .utf8) {
            totalLines = data.components(separatedBy: .newlines).count
        }

        parser = xmlParser
        parser?.delegate = self
        parser?.parse()
    }

    // MARK: - Progress

    private func updateProgress(for line: Int, isUpdateToMaxProgress: Bool = false) {
        let maxProgress = isUpdateToMaxProgress ? Constants.maxProgress : Constants.minProgress
        let progress = Int((Double(line) / Double(totalLines) * 100)/*.rounded(.up)*/)
        self.progress = max(progress, maxProgress)
    }
}

// MARK: - XMLParserDelegate

extension RSSParser: XMLParserDelegate {

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {

        updateProgress(for: parser.lineNumber)

        tempElement = elementName
        if elementName == XMLParam.item.rawValue {
            tempPost = Post()
        }
        if elementName == XMLParam.mediaContent.rawValue && tempPost?.imageUrl == nil,
            let imageUrlIndex = attributeDict.index(forKey: XMLParam.url.rawValue) {
            tempPost?.imageUrl = attributeDict[imageUrlIndex].value
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {

        guard let post = tempPost, let tempElement = tempElement else {
            return
        }

        let text = string.trimmingCharacters(in: .controlCharacters)

        switch tempElement {
        case XMLParam.title.rawValue:
            tempPost?.title = post.title ?? "" + text
        case XMLParam.link.rawValue:
            tempPost?.postUrl = post.postUrl ?? "" + text
        case XMLParam.pubDate.rawValue:
            tempPost?.date = post.date ?? "" + text
        case XMLParam.mediaContent.rawValue:
            tempPost?.imageUrl = post.imageUrl ?? "" + text
        default:
            break
        }
    }


    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {

        guard elementName == XMLParam.item.rawValue,
            let post = tempPost,
            let postTitle = post.title,
            !postsTitles.contains(postTitle) else {
            return
        }

        posts?.append(post)
        kvoPosts.append(post)
        tempPost = nil
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        delegate?.parserError(.nativeXMLParserError(parseError))
    }

    func parserDidEndDocument(_ parser: XMLParser) {
        updateProgress(for: 0, isUpdateToMaxProgress: true)
        guard let posts = posts else {
            delegate?.updatePosts([])
            return
        }
        delegate?.updatePosts(posts)
    }
}
