//
//  PostModel.swift
//  Musictory
//
//  Created by 김상규 on 8/19/24.
//

import Foundation

// 게시물 모델
struct PostModel: Decodable {
    let postID: String?
    let title: String?
    let content: String?
    let content1: String? // 노래 id
    let content2: String? // 노래 제목
    let content3: String? // 가창자 이름
    let content4: String? // 위도
    let content5: String? // 경도
    let creator: User? // 작성자(유저 구조체 만들기)
    let files: [String]? // 이미지 파일
    let likes: [String]? // 좋아요한 사람 id(좋아요 개수로 만들기)
    let hashTags: [String]? // 해시태그(해시태그로 검색하기 기능)
    let createdAt: String? // 게시물 생성 날짜
    let comments: [CommentModel]? // 댓글 모음(댓글 구조체 만들기)
    
    enum CodingKeys: String, CodingKey {
        case postID = "post_id"
        case title
        case content
        case content1
        case content2
        case content3
        case content4
        case content5
        case creator
        case files
        case likes
        case hashTags
        case createdAt
        case comments
    }
}
