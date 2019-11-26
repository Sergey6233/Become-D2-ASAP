//
//  NewsTableViewCell.swift
//  RSS Reader
//
//  Created by Sergey Bizunov on 11/25/19.
//  Copyright © 2019 Sergey Bizunov. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell, ReuseIdentifierSupportable {

    @IBOutlet private weak var postTitle: UILabel!
    @IBOutlet private weak var postDetails: UILabel!
    @IBOutlet private weak var postDate: UILabel!
    @IBOutlet private weak var postImage: UIImageView!

    var post: Post? {
        didSet {
            setup()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        postTitle.text = nil
        postDetails.text = nil
        postDate.text = nil
        postImage.image = nil
    }

    private func setup() {
        guard let post = post else {
            prepareForReuse()
            return
        }

        postTitle.text = post.title
        postDetails.text = nil // TODO
        postDate.text = post.date
        guard let imageUrl = post.imageUrl, let url = URL(string: imageUrl) else {
            return
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let imageData = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    if imageUrl == self?.post?.imageUrl {
                        self?.postImage.image = UIImage(data: imageData)
                    }
                }
            }
        }
    }
}
