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

    private var posts = [Post]() {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupParser()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        parser = nil
    }

    private func setupParser() {
        parser = RSSParser(urlPath: Constants.grodnoRssUrlPath)
        parser?.delegate = self
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.parser?.parse()
        }
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.reuseIdentifier, for: indexPath) as? NewsTableViewCell else {
            assertionFailure("WARNING: Needs to fix the NewsTableViewCell !")
            return UITableViewCell()
        }
        cell.post = posts[indexPath.row]
        return cell
    }
}

// MARK: - RSSParserDelegate

extension NewsTableViewController: RSSParserDelegate {

    func updatePosts(_ posts: [Post]) {
        self.posts = posts
    }

    func parserError(_ error: RSSParserError) {
        switch error {
        case .invalidUrl:
            print("⚠️ [RSSParser Error] description: invalid URL!")
        case .nativeXMLParserError(let nativeError):
            print("⚠️ [Native XMLParser Error] description: \(nativeError.localizedDescription)!")
        }
    }
}
