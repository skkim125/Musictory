//
//  LoginModel.swift
//  Musictory
//
//  Created by 김상규 on 8/18/24.
//

import Foundation

struct LoginModel: Decodable {
    let userID: String
    let email: String
    let nick: String
    let profileImage: String?
    let accessT: String
    let refreshT: String
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case email
        case nick
        case profileImage
        case accessT = "accessToken"
        case refreshT = "refreshToken"
    }
}
