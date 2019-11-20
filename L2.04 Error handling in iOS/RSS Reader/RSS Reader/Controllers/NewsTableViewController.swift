//
//  NewsTableViewController.swift
//  RSS Reader
//
//  Created by Sergey Bizunov on 11/18/19.
//  Copyright © 2019 Sergey Bizunov. All rights reserved.
//

import UIKit

class NewsTableViewController: UITableViewController {

    private struct Constants {
        static let grodnoRssUrlPath = "https://news.tut.by/rss/geonews/grodno.rss"
    }

    private var parser: RSSParser?

    private var posts = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupParser()
    }

    private func setupParser() {
        parser = RSSParser(urlPath: Constants.grodnoRssUrlPath)
        parser?.delegate = self
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.parser?.parse()
        }
    }
}

extension NewsTableViewController: RSSParserDelegate {

    func updatePosts(_ posts: [Post]) {
        print("Found \(posts.count) posts")
    }

    func parserError(_ error: RSSParserError) {
        switch error {
        case .invalidUrl:
            // TODO
            break
        case .nativeXMLParserError(let nativeError):
            print("⚠️ [Native XMLParser Error] description: \(nativeError.localizedDescription)")
        }
    }
}
