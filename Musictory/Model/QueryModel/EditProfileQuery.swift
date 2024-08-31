//
//  EditProfileQuery.swift
//  Musictory
//
//  Created by 김상규 on 8/31/24.
//

import Foundation

struct EditProfileQuery {
    let boundary = UUID().uuidString
    let nick: String
    let profile: Data
}
