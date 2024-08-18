//
//  LSLPRouter.swift
//  Musictory
//
//  Created by 김상규 on 8/18/24.
//

import Foundation

enum LSLPRouter {
    case login(LoginQuery)
    case fetchPost(String)
    case refresh
}

extension LSLPRouter {

    var baseURL: String {
        return APIURL.baseURL + "v1"
    }
    
    var method: String {
        switch self {
        case .login:
            "POST"
        case .fetchPost, .refresh:
            "GET"
        }
    }
    
    var path: String {
        switch self {
        case .login:
            APIPath.login
        case .fetchPost:
            ""
        case .refresh:
            ""
        }
    }
    
    var header: [String: String] {
        switch self {
        case .login:
            [
                APIKey.sesac: APIKey.key,
                APIHeader.contentType: APIHeader.json
            ]
        case .fetchPost:
            [
                APIKey.sesac: APIKey.key,
                APIHeader.contentType: APIHeader.json
            ]
        case .refresh:
            [
                APIKey.sesac: APIKey.key,
                APIHeader.contentType: APIHeader.json
            ]
        }
    }
    
    var httpBody: Data? {
        switch self {
        case .login(let loginQuery):
            let encoder = JSONEncoder()
            return try? encoder.encode(loginQuery)
        default:
            return nil
        }
    }
    
    func errorHandler(statusCode: Int) -> NetworkError {
        switch self {
        case .login:
            switch statusCode {
            case 401:
                return NetworkError.custom("유효하지 않은 계정입니다.")
            default:
                return NetworkError.custom("")
            }
        case .fetchPost:
            switch statusCode {
            default:
                return NetworkError.custom("")
            }
        case .refresh:
            switch statusCode {
            default:
                return NetworkError.custom("")
            }
        }
    }
}


enum NetworkError: Error {
    case custom(String)
}

