//
//  UserModel.swift
//  Musictory
//
//  Created by 김상규 on 8/19/24.
//

import Foundation

// 유저 모델
struct User: Decodable, Hashable {
    let userID: String
    var nickname: String
    var profileImage: String?
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case nickname = "nick"
        case profileImage
    }
}
