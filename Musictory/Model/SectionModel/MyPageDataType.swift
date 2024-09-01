//
//  MyPageDataType.swift
//  Musictory
//
//  Created by 김상규 on 9/1/24.
//

import Foundation
import RxDataSources

enum MyPageDataType {
    case profile(items: [MyPageItem])
    case post(items: [MyPageItem])
}

extension MyPageDataType: SectionModelType {
    typealias Item = MyPageItem
    
    var items: [MyPageItem] {
        switch self {
        case .profile(items: let items):
            return items.map { $0 }
        case .post(items: let items):
            return items.map { $0 }
        }
    }
    
    init(original: MyPageDataType, items: [Item]) {
        switch original {
        case .profile(items: let items):
            self = .post(items: items)
        case .post(items: let items):
            self = .post(items: items)
        }
    }
}

enum MyPageItem {
    case profileItem(item: ProfileModel)
    case postItem(item: ConvertPost)
}
