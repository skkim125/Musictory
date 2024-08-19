//
//  RequsetPostModel.swift
//  Musictory
//
//  Created by 김상규 on 8/19/24.
//

import Foundation

struct RequestPostModel: Decodable {
    let data: [PostModel]
    let nextCursor: String?
    
    enum CodingKeys: String, CodingKey {
        case data
        case nextCursor = "next_cursor"
    }
}
