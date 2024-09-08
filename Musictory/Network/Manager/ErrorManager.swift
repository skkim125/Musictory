//
//  ErrorManager.swift
//  Musictory
//
//  Created by 김상규 on 9/7/24.
//

import Foundation

final class ErrorManager {
    static let shared = ErrorManager()
    private init() { }
    // 400, 401, 402, 403, 409, 410, 418, 419, 420, 429, 444, 445, 500
    // 420(헤더의 키값 누락), 429(과호출), 444(비정상 URL), 500(비정상 요청) : 공통 상태코드
    
    // 포스트 삭제: 401, 403, 410, 419, 445(게시물 삭제권한X)
    // 댓글 삭제: 401, 403, 410, 419, 445
    func errorHandler(api: LSLPRouter, statusCode: Int) -> NetworkError {
        switch api {
        case .login:
            switch statusCode {
            case 400:
                return NetworkError.badRequest
            case 401:
                return NetworkError.unauthorized
            case 420:
                return NetworkError.wrongHeader
            case 429:
                return NetworkError.toManyRequests
            case 444:
                return NetworkError.noResponse
            case 500:
                return NetworkError.serverError
            default:
                return NetworkError.unknownError
            }
            
        case .refresh:
            switch statusCode {
            case 400:
                return NetworkError.badRequest
            case 401:
                return NetworkError.unauthorized
            case 403:
                return NetworkError.forbidden
            case 418:
                return NetworkError.expiredRefreshToken
            case 419:
                return NetworkError.expiredAccessToken
            case 420:
                return NetworkError.wrongHeader
            case 429:
                return NetworkError.toManyRequests
            case 444:
                return NetworkError.noResponse
            case 500:
                return NetworkError.serverError
            default:
                return NetworkError.unknownError
                
            }
        case .fetchPost:
            switch statusCode {
            case 400:
                return NetworkError.badRequest
            case 401:
                return NetworkError.unauthorized
            case 403:
                return NetworkError.forbidden
            case 419:
                return NetworkError.expiredAccessToken
            case 420:
                return NetworkError.wrongHeader
            case 429:
                return NetworkError.toManyRequests
            case 444:
                return NetworkError.noResponse
            case 500:
                return NetworkError.serverError
            default:
                return NetworkError.unknownError
            }
        case .writePost:
            switch statusCode {
            case 400:
                return NetworkError.badRequest
            case 401:
                return NetworkError.unauthorized
            case 403:
                return NetworkError.forbidden
            case 410:
                return NetworkError.noPost
            case 419:
                return NetworkError.expiredAccessToken
            case 420:
                return NetworkError.wrongHeader
            case 429:
                return NetworkError.toManyRequests
            case 444:
                return NetworkError.noResponse
            case 500:
                return NetworkError.serverError
            default:
                return NetworkError.unknownError
            }
        case .like:
            switch statusCode {
            case 400:
                return NetworkError.badRequest
            case 401:
                return NetworkError.unauthorized
            case 403:
                return NetworkError.forbidden
            case 410:
                return NetworkError.noPost
            case 419:
                return NetworkError.expiredAccessToken
            case 420:
                return NetworkError.wrongHeader
            case 429:
                return NetworkError.toManyRequests
            case 444:
                return NetworkError.noResponse
            case 500:
                return NetworkError.serverError
            default:
                return NetworkError.unknownError
            }
        case .fetchPostOfReload:
            switch statusCode {
            case 400:
                return NetworkError.badRequest
            case 401:
                return NetworkError.unauthorized
            case 403:
                return NetworkError.forbidden
            case 419:
                return NetworkError.expiredAccessToken
            case 420:
                return NetworkError.wrongHeader
            case 429:
                return NetworkError.toManyRequests
            case 444:
                return NetworkError.noResponse
            case 500:
                return NetworkError.serverError
            default:
                return NetworkError.unknownError
            }
        case .fetchProfile:
            switch statusCode {
            case 401:
                return NetworkError.unauthorized
            case 403:
                return NetworkError.forbidden
            case 419:
                return NetworkError.expiredAccessToken
            case 420:
                return NetworkError.wrongHeader
            case 429:
                return NetworkError.toManyRequests
            case 444:
                return NetworkError.noResponse
            case 500:
                return NetworkError.serverError
            default:
                return NetworkError.unknownError
            }
        case .uploadImage:
            switch statusCode {
            case 400:
                return NetworkError.badRequest
            case 401:
                return NetworkError.unauthorized
            case 403:
                return NetworkError.forbidden
            case 419:
                return NetworkError.expiredAccessToken
            case 420:
                return NetworkError.wrongHeader
            case 429:
                return NetworkError.toManyRequests
            case 444:
                return NetworkError.noResponse
            case 500:
                return NetworkError.serverError
            default:
                return NetworkError.unknownError
            }
        case .fetchMyPost:
            switch statusCode {
            case 400:
                return NetworkError.badRequest
            case 401:
                return NetworkError.unauthorized
            case 403:
                return NetworkError.forbidden
            case 419:
                return NetworkError.expiredAccessToken
            case 420:
                return NetworkError.wrongHeader
            case 429:
                return NetworkError.toManyRequests
            case 444:
                return NetworkError.noResponse
            case 500:
                return NetworkError.serverError
            default:
                return NetworkError.unknownError
            }
        case .writeComment:
            switch statusCode {
            case 400:
                return NetworkError.badRequest
            case 401:
                return NetworkError.unauthorized
            case 403:
                return NetworkError.forbidden
            case 410:
                return NetworkError.noPost
            case 419:
                return NetworkError.expiredAccessToken
            case 420:
                return NetworkError.wrongHeader
            case 429:
                return NetworkError.toManyRequests
            case 444:
                return NetworkError.noResponse
            case 500:
                return NetworkError.serverError
            default:
                return NetworkError.unknownError
            }
        case .editMyProfile:
            switch statusCode {
            case 400:
                return NetworkError.badRequest
            case 401:
                return NetworkError.unauthorized
            case 403:
                return NetworkError.forbidden
            case 409:
                return NetworkError.isUsedNickname
            case 419:
                return NetworkError.expiredAccessToken
            case 420:
                return NetworkError.wrongHeader
            case 429:
                return NetworkError.toManyRequests
            case 444:
                return NetworkError.noResponse
            case 500:
                return NetworkError.serverError
            default:
                return NetworkError.unknownError
            }
        case .donation:
            switch statusCode {
            case 401:
                return NetworkError.unauthorized
            case 419:
                return NetworkError.expiredAccessToken
            case 420:
                return NetworkError.wrongHeader
            case 429:
                return NetworkError.toManyRequests
            case 444:
                return NetworkError.noResponse
            case 500:
                return NetworkError.serverError
            default:
                return NetworkError.unknownError
            }
        case .withdraw:
            switch statusCode {
            case 401:
                return NetworkError.unauthorized
            case 403:
                return NetworkError.forbidden
            case 419:
                return NetworkError.expiredAccessToken
            case 420:
                return NetworkError.wrongHeader
            case 429:
                return NetworkError.toManyRequests
            case 444:
                return NetworkError.noResponse
            case 500:
                return NetworkError.serverError
            default:
                return NetworkError.unknownError
            }
            
        case .deletePost:
            switch statusCode {
            case 401:
                return NetworkError.unauthorized
            case 403:
                return NetworkError.forbidden
            case 419:
                return NetworkError.expiredAccessToken
            case 420:
                return NetworkError.wrongHeader
            case 429:
                return NetworkError.toManyRequests
            case 444:
                return NetworkError.noResponse
            case 500:
                return NetworkError.serverError
            default:
                return NetworkError.unknownError
            }
        }
    }
}
