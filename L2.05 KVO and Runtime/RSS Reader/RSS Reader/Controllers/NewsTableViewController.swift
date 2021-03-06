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

    private struct Settings {
        static let useKVO = true
    }

    @objc private var parser: RSSParser?

    private var posts = [Post]() {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }

    private var postsObserver: NSKeyValueObservation?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupParser()
        setupObserver()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        parser = nil
        postsObserver = nil
    }

    private func setupParser() {
        parser = RSSParser(urlPath: Constants.grodnoRssUrlPath)
        parser?.delegate = self
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.parser?.parse()
        }
    }

    private func setupObserver() {
        guard Settings.useKVO, postsObserver == nil else {
            return
        }
        postsObserver = observe(\.parser?.kvoPosts, options: [.new]) { (observer, change) in
            guard let newPosts = change.newValue, let newPostsCount = newPosts?.count else {
                return
            }
            print("==> [KVO] posts observer: \(type(of: observer)), posts count: \(newPostsCount)")
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

    func updateProgress(_ progress: Int, isUpdateToMaxProgress: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.navigationItem.title = isUpdateToMaxProgress ? nil : "\(progress) %"
        }
        print(">> [News Controller] progress: \(progress)")
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
