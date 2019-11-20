//
//  RSSParserError.swift
//  RSS Reader
//
//  Created by Sergey Bizunov on 11/19/19.
//  Copyright © 2019 Sergey Bizunov. All rights reserved.
//

enum RSSParserError: Error {
    case invalidUrl
    case nativeXMLParserError(Error)
}
