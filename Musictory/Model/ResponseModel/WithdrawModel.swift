//
//  WithdrawModel.swift
//  Musictory
//
//  Created by 김상규 on 9/7/24.
//

import Foundation

struct WithdrawModel: Decodable {
    let userID: String
    let email: String
    let nick: String
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case email
        case nick
    }
}
