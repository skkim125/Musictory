//
//  NetworkError.swift
//  Musictory
//
//  Created by 김상규 on 9/7/24.
//

import Foundation

enum NetworkError: Equatable, Error {
    /// MARK: - 400
    case badRequest
    /// MARK: - 401
    case unauthorized
    /// MARK: - 402
    case noBlankNickname
    /// MARK: - 403
    case forbidden
    /// MARK: - 409
    case isUsedNickname
    /// MARK: - 410
    case noPost
    /// MARK: - 418
    case expiredRefreshToken
    /// MARK: - 419
    case expiredAccessToken
    /// MARK: - 420
    case wrongHeader
    /// MARK: - 429
    case toManyRequests
    /// MARK: - 444
    case noResponse
    /// MARK: - 500
    case serverError
    /// MARK: - unknown
    case unknownError
    /// MARK: - decodingError
    case decodingError
    
    var title: String {
        switch self {
        case .badRequest:
            "유효하지 않은 요청입니다."
        case .unauthorized:
            "확인할 수 없는 계정입니다."
        case .noResponse:
            "응답을 받지 못했습니다."
        case .forbidden:
            "접근할 수 없는 상태입니다."
        case .expiredRefreshToken:
            "로그인 시간이 만료되었습니다."
        default:
            "알 수 없는 에러입니다."
        }
    }
    
    var alertMessage: String {
        switch self {
        case .expiredRefreshToken:
            "로그인 화면으로 이동합니다."
        default:
            "잠시 후 다시 시도해주세요"
        }
    }
}
