//
//  MusicKitError.swift
//  Musictory
//
//  Created by 김상규 on 9/8/24.
//

import Foundation

enum MusicKitError: Error {
    case denied
    case networkError
    case noResponse
    case noResult
    case unknownError
    
    var alertTitle: String {
        switch self {
        case .denied:
            "미디어 권한이 허용되어있지 않습니다."
        case .networkError:
            "네트워크를 연결할 수 없습니다."
        case .noResponse:
            "검색 결과를 불러올 수 없습니다."
        case .noResult:
            "검색 결과가 없습니다."
        case .unknownError:
            "알 수 없는 에러입니다."
        }
    }
    
    var alertMessage: String {
        switch self {
        case .noResult:
            "다른 검색어를 입력해주세요"
        case .denied:
            "권한을 허용하러 이동합니다."
        default:
            "잠시 후 다시 시도해주세요."
        }
    }
}
