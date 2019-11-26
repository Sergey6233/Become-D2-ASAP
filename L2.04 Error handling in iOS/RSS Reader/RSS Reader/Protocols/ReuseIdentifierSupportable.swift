//
//  ReuseIdentifierSupportable.swift
//  RSS Reader
//
//  Created by Sergey Bizunov on 11/25/19.
//  Copyright © 2019 Sergey Bizunov. All rights reserved.
//

import Foundation

protocol ReuseIdentifierSupportable {
    static var reuseIdentifier: String { get }
}

extension ReuseIdentifierSupportable {
    static var reuseIdentifier: String {
        return "\(self.self)"
    }

}
