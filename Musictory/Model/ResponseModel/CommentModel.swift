//
//  CommentModel.swift
//  Musictory
//
//  Created by 김상규 on 8/19/24.
//

import Foundation

// 댓글 모델
struct CommentModel: Decodable {
    let comment_id: String
    let content: String
    let createdAt: String
    let creator: User
}
