//
//  PostDetailType.swift
//  Musictory
//
//  Created by 김상규 on 9/1/24.
//

import Foundation
import RxDataSources

enum PostDetailDataType {
    case post(items: [PostDetailItem])
    case comments(items: [PostDetailItem])
}

extension PostDetailDataType: SectionModelType {
    typealias Item = PostDetailItem
    
    var items: [PostDetailItem] {
        switch self {
        case .post(items: let items):
            return items.map { $0 }
        case .comments(items: let items):
            return items.map { $0 }
        }
    }
    
    init(original: PostDetailDataType, items: [Item]) {
        switch original {
        case .post(items: let items):
            self = .post(items: items)
        case .comments(items: let items):
            self = .comments(items: items)
        }
    }
}

enum PostDetailItem {
    case postItem(item: PostModel)
    case commentItem(item: CommentModel)
}
