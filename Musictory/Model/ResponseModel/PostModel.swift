//
//  PostModel.swift
//  Musictory
//
//  Created by 김상규 on 8/19/24.
//

import Foundation
import MusicKit

// 게시물 모델
struct PostModel: Decodable, Hashable {
    let postID: String
    let title: String // 게시물 제목
    let content: String // 게시물 내용
    let content1: String // 노래 id
    let content2: String? // 위도
    let content3: String? // 경도
    var creator: User // 작성자(유저 구조체 만들기)
    let files: [String]? // 이미지 파일
    var likes: [String] // 좋아요한 사람 id(좋아요 개수로 만들기)
    let hashTags: [String] // 해시태그(해시태그로 검색하기 기능)
    let createdAt: String // 게시물 생성 날짜
    var comments: [CommentModel] // 댓글 모음(댓글 구조체 만들기)
    
    enum CodingKeys: String, CodingKey {
        case postID = "post_id"
        case title
        case content
        case content1
        case content2
        case content3
        case creator
        case files
        case likes
        case hashTags
        case createdAt
        case comments
    }
}
