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
            APIPath.login.rawValue
        case .fetchPost:
            APIPath.fetchPost.rawValue
        case .refresh:
            ""
        }
    }
    
    var header: [String: String] {
        switch self {
        case .login:
            [
                APIHeader.sesac.rawValue: APIKey.key,
                APIHeader.contentType.rawValue: APIHeader.json.rawValue
            ]
        case .fetchPost:
            [
                APIHeader.sesac.rawValue: APIKey.key,
                APIHeader.authorization.rawValue: UserDefaultsManager.shared.accessT
            ]
        case .refresh:
            [
                APIHeader.sesac.rawValue: APIKey.key,
                APIHeader.contentType.rawValue: APIHeader.json.rawValue,
                APIHeader.authorization.rawValue: UserDefaultsManager.shared.accessT,
                APIHeader.refresh.rawValue: UserDefaultsManager.shared.refreshT
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
            case 419:
                return NetworkError.expiredAccessToken
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
                return NetworkError.expiredAccessToken
            default:
                return NetworkError.custom("확인할 수 없는 에러")
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
    case expiredAccessToken
    case decodingError(String)
}

