//
//  LSLPRouter.swift
//  Musictory
//
//  Created by 김상규 on 8/18/24.
//

import Foundation

enum LSLPRouter {
    case login(LoginQuery)
    case fetchPost(PostQuery)
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
            APIPath.fetchPost
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
                APIHeader.authorization: UserDefaultsManager.shared.accessT
            ]
        case .refresh:
            [
                APIKey.sesac: APIKey.key,
                APIHeader.contentType: APIHeader.json
            ]
        }
    }
    
    var parameters: [URLQueryItem]? {
        switch self {
        case .fetchPost(let postQuery):
            return [
                URLQueryItem(name: "product_id", value: postQuery.product_id),
                URLQueryItem(name: "limit", value: postQuery.limit),
                URLQueryItem(name: "next", value: postQuery.next)
            ]
        default:
            return nil
        }
    }
    
    var httpBody: Data? {
        let encoder = JSONEncoder()
        
        switch self {
        case .login(let loginQuery):
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
            case 400:
                return NetworkError.custom("잘못된 요청입니다.")
            case 401:
                return NetworkError.custom("인증할 수 없는 액세스 토큰입니다.")
            case 403:
                return NetworkError.custom("접근 권한이 없습니다.")
            case 419:
                return NetworkError.custom("액세스 토큰이 만료되었습니다.")
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
    case decodingError(String)
}

