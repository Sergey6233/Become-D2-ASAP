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

    private var parser: RssParser?

    private var rssItems = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupParser()
    }

    private func setupParser() {
        parser = RssParser(urlPath: Constants.grodnoRssUrlPath)
        parser?.delegate = self
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.parser?.parse()
        }
    }
}

extension NewsTableViewController: RssParserDelegate {
    func updateNews(_ news: String) {
        print("News update result: \(news)")
    }


    func parserError() {
        print("⚠️ Error during parsing")
    }
}
