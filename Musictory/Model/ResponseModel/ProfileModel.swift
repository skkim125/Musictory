//
//  ProfileModel.swift
//  Musictory
//
//  Created by 김상규 on 8/24/24.
//

import Foundation

struct ProfileModel: Decodable, Hashable {
    let user_id: String
    let email: String
    let nick: String
    let followers: [User]
    let following: [User]
    let posts: [String]
    let profileImage: String?
}
