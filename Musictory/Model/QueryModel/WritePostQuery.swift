//
//  WritePostQuery.swift
//  Musictory
//
//  Created by 김상규 on 8/22/24.
//

import Foundation

struct WritePostQuery: Encodable {
    let product_id: String = "Musictory"
    let title: String // 제목
    let content: String // 컨텐츠
    let content1: String // 노래 id
    let content2: String? // 위도
    let content3: String? // 경도
    let files: [String]? // 사진 url
}
