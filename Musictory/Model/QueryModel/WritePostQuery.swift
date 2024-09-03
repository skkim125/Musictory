//
//  WritePostQuery.swift
//  Musictory
//
//  Created by 김상규 on 8/22/24.
//

import Foundation

struct WritePostQuery: Encodable {
    let product_id: String = "Musictory"
    var title: String // 제목
    var content: String // 컨텐츠
    var content1: String // 노래 id
    var content2: String? // 위도
    var content3: String? // 경도
    var files: [String]? // 사진 url
}
