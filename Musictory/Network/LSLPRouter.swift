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
    case fetchPostOfReload(String, PostQuery)
    case writePost(WritePostQuery)
    case refresh
    case like(String, LikeQuery)
    case fetchProfile
    case fetchMyPost(PostQuery)
    case uploadImage(Data, String)
    case writeComment(String, CommentsQuery)
}

extension LSLPRouter {

    var baseURL: String {
        return APIURL.baseURL + "v1"
    }
    
    var method: String {
        switch self {
        case .login, .writePost, .like, .uploadImage, .writeComment:
            "POST"
        case .fetchPost, .fetchPostOfReload, .fetchProfile, .refresh, .fetchMyPost:
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
        case .like(let id, _):
            APIPath.fetchPost.rawValue + "/\(id)/like"
        case .fetchPostOfReload(let id, _):
            APIPath.fetchPost.rawValue + "/\(id)"
        case .fetchProfile:
            APIPath.fetchProfile.rawValue
        case .uploadImage:
            APIPath.fetchPost.rawValue + "/files"
        case .fetchMyPost:
            APIPath.fetchPost.rawValue + "/users" + "/\(UserDefaultsManager.shared.userID)"
        case .writeComment(let id, _):
            APIPath.fetchPost.rawValue + "/\(id)" + "/comments"
        }
    }
    
    var header: [String: String] {
        switch self {
        case .login:
            [
                APIHeader.sesac.rawValue: APIKey.key,
                APIHeader.contentType.rawValue: APIHeader.json.rawValue
            ]
        case .fetchPost, .fetchPostOfReload, .fetchProfile, .fetchMyPost:
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
        case .writePost, .like, .writeComment:
            [
                APIHeader.sesac.rawValue: APIKey.key,
                APIHeader.authorization.rawValue: UserDefaultsManager.shared.accessT,
                APIHeader.contentType.rawValue: APIHeader.json.rawValue
            ]
        case .uploadImage(_, let boundary): // UUID().uuidString
            [
                APIHeader.sesac.rawValue: APIKey.key,
                APIHeader.authorization.rawValue: UserDefaultsManager.shared.accessT,
                APIHeader.contentType.rawValue: APIHeader.multipart.rawValue + "; boundaryBoundary-\(boundary)"
            ]
        }
    }
    
    var parameters: [URLQueryItem]? {
        switch self {
        case .fetchPost(let postQuery), .fetchPostOfReload(_, let postQuery), .fetchMyPost(let postQuery):
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
        case .like(_, let likeQuery):
            return try? encoder.encode(likeQuery)
        case .uploadImage(let image, let boundary):
            var body = Data()
            
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(image)
            body.append("\r\n".data(using: .utf8)!)
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)
            
            return body
        case .writeComment( _, let commentQuery):
            return try? encoder.encode(commentQuery)
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
                return NetworkError.expiredRefreshToken
            case 403:
                return NetworkError.custom("접근 권한이 없습니다.")
            case 419:
                return NetworkError.expiredAccessToken
            default:
                return NetworkError.custom("알 수 없는 에러입니다.")
            }
        case .refresh:
            switch statusCode {
            case 401:
                return NetworkError.expiredRefreshToken
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
        case .like:
            switch statusCode {
            case 410:
                return NetworkError.custom("삭제된 게시물입니다.")
            case 419:
                return NetworkError.expiredAccessToken
            default:
                return NetworkError.custom("\(statusCode)")
            }
        case .fetchPostOfReload:
            switch statusCode {
            case 419:
                return NetworkError.expiredAccessToken
            default:
                return NetworkError.custom("\(statusCode)")
            }
            
        case .fetchProfile:
            switch statusCode {
            case 419:
                return NetworkError.expiredAccessToken
            default:
                return NetworkError.custom("\(statusCode)")
            }
            
        case .uploadImage:
            switch statusCode {
            case 419:
                return NetworkError.expiredAccessToken
            default:
                return NetworkError.custom("\(statusCode)")
            }
        case .fetchMyPost(_):
            switch statusCode {
            case 419:
                return NetworkError.expiredAccessToken
            default:
                return NetworkError.custom("\(statusCode)")
            }
        case .writeComment(_, _):
            switch statusCode {
            case 419:
                return NetworkError.expiredAccessToken
            default:
                return NetworkError.custom("\(statusCode)")
            }
        }
    }
}


enum NetworkError: Equatable, Error {
    case responseError(String)
    case custom(String)
    case expiredAccessToken
    case expiredRefreshToken
    case decodingError(String)
    
    var title: String {
        switch self {
        case .responseError(let error):
            "\(error)"
        case .custom(let error):
            "\(error)"
        case .expiredAccessToken:
            "로그인 시간이 만료되었습니다."
        case .expiredRefreshToken:
            "로그인 시간이 만료되었습니다."
        case .decodingError(let error):
            "\(error)"
        }
    }
    
    var alertMessage: String {
        switch self {
        case .custom:
            "새로고침해주세요"
        case .expiredAccessToken, .expiredRefreshToken:
            "로그인 화면으로 이동합니다."
        default:
            "다시 시도해주세요"
        }
    }
}

