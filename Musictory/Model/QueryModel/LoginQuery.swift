//
//  LoginQuery.swift
//  Musictory
//
//  Created by 김상규 on 8/18/24.
//

import Foundation

struct LoginQuery: Encodable {
    var email: String
    var password: String
}