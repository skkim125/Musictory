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
    case writePost(WritePostQuery)
    case refresh
}

extension LSLPRouter {

    var baseURL: String {
        return APIURL.baseURL + "v1"
    }
    
    var method: String {
        switch self {
        case .login, .writePost:
            "POST"
        case .fetchPost, .refresh:
            "GET"
        }
    }
    
    var path: String {
        switch self {
        case .login:
            APIPath.login.rawValue
        case .fetchPost, .writePost:
            APIPath.fetchPost.rawValue
        case .refresh:
            APIPath.refresh.rawValue
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
        case .writePost:
            [
                APIHeader.sesac.rawValue: APIKey.key,
                APIHeader.authorization.rawValue: UserDefaultsManager.shared.accessT,
                APIHeader.contentType.rawValue: APIHeader.json.rawValue
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
        case .writePost(let writePostQuery):
            return try? encoder.encode(writePostQuery)
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
                return NetworkError.custom("알 수 없는 에러입니다.")
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
                return NetworkError.custom("알 수 없는 에러입니다.")
            }
        case .refresh:
            switch statusCode {
            case 418:
                return NetworkError.expiredRefreshToken
            default:
                return NetworkError.custom("알 수 없는 에러입니다.")
            }
        case .writePost:
            switch statusCode {
            case 400...410:
                return NetworkError.custom("게시글을 생성할 수 없습니다.")
            case 419:
                return NetworkError.expiredAccessToken
            default:
                return NetworkError.custom("알 수 없는 에러입니다.")
            }
        }
    }
}


enum NetworkError: Error {
    case custom(String)
    case expiredAccessToken
    case expiredRefreshToken
    case decodingError(String)
    
    var title: String {
        switch self {
        case .custom(let error):
            "\(error)"
        case .expiredAccessToken:
            "토큰이 만료되었습니다."
        case .expiredRefreshToken:
            "리프래시 토큰이 만료되었습니다."
        case .decodingError(let error):
            "\(error)"
        }
    }
    
    var alertMessage: String {
        "다시 시도해주세요"
    }
}

