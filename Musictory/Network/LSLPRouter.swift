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
    case uploadImage(ImageQuery)
    case writeComment(String, CommentsQuery)
    case editMyProfile(EditProfileQuery)
    case donation(DonationQuery)
    case withdraw
}

extension LSLPRouter {

    var baseURL: String {
        return APIURL.baseURL + "v1"
    }
    
    var method: String {
        switch self {
        case .login, .writePost, .like, .uploadImage, .writeComment, .donation:
            "POST"
        case .fetchPost, .fetchPostOfReload, .fetchProfile, .refresh, .fetchMyPost, .withdraw:
            "GET"
        case .editMyProfile:
            "PUT"
        }
    }
    
    var path: String {
        switch self {
        case .login:
            APIPath.user.rawValue + "/login"
        case .fetchPost, .writePost:
            APIPath.post.rawValue
        case .refresh:
            APIPath.refresh.rawValue
        case .like(let id, _):
            APIPath.post.rawValue + "/\(id)/like"
        case .fetchPostOfReload(let id, _):
            APIPath.post.rawValue + "/\(id)"
        case .fetchProfile, .editMyProfile:
            APIPath.user.rawValue + APIPath.my.rawValue + APIPath.profile.rawValue
        case .uploadImage:
            APIPath.post.rawValue + "/files"
        case .fetchMyPost:
            APIPath.post.rawValue + APIPath.user.rawValue + "/\(UserDefaultsManager.shared.userID)"
        case .writeComment(let id, _):
            APIPath.post.rawValue + "/\(id)" + "/comments"
        case .donation:
            "/payments/validation"
        case .withdraw:
            APIPath.user.rawValue + "/withdraw"
        }
    }
    
    var header: [String: String] {
        switch self {
        case .login:
            [
                APIHeader.sesac.rawValue: APIKey.key,
                APIHeader.contentType.rawValue: APIHeader.json.rawValue
            ]
        case .fetchPost, .fetchPostOfReload, .fetchProfile, .fetchMyPost, .withdraw:
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
        case .writePost, .like, .writeComment, .donation:
            [
                APIHeader.sesac.rawValue: APIKey.key,
                APIHeader.authorization.rawValue: UserDefaultsManager.shared.accessT,
                APIHeader.contentType.rawValue: APIHeader.json.rawValue
            ]
        case .uploadImage, .editMyProfile:
            [
                APIHeader.sesac.rawValue: APIKey.key,
                APIHeader.authorization.rawValue: UserDefaultsManager.shared.accessT,
                APIHeader.contentType.rawValue: APIHeader.multipart.rawValue
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
            
        case .uploadImage(let imageQuery):
            var body = Data()
            
            body.append("--\(imageQuery.boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"files\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageQuery.imageData ?? Data())
            body.append("\r\n".data(using: .utf8)!)
            body.append("--\(imageQuery.boundary)--\r\n".data(using: .utf8)!)
            
            return body
            
        case .writeComment( _, let commentQuery):
            return try? encoder.encode(commentQuery)
            
        case .editMyProfile(let editProfile):
            
            var body = Data()
            
            body.append("--\(editProfile.boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"nick\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: application/json\r\n\r\n".data(using: .utf8)!)
            body.append(editProfile.nick.data(using: .utf8)!)
            body.append("\r\n".data(using: .utf8)!)
            
            body.append("--\(editProfile.boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"profile\"; filename=\"image.png\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
            body.append(editProfile.profile)
            body.append("\r\n".data(using: .utf8)!)
            body.append("--\(editProfile.boundary)--\r\n".data(using: .utf8)!)
            
            return body
            
        case .donation(let donationQuery):
            return try? encoder.encode(donationQuery)
        default:
            return nil
        }
    }
    
    var boundary: String? {
        switch self {
        case .editMyProfile(let editProfileQuery):
            editProfileQuery.boundary
        case .uploadImage(let imageQuery):
            imageQuery.boundary
        default:
            nil
        }
    }
}
