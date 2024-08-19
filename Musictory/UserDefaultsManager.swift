//
//  UserDefaultsManager.swift
//  Musictory
//
//  Created by 김상규 on 8/19/24.
//

import Foundation

final class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private init () { }
    
    private let userDefaults = UserDefaults.standard
    
    private enum UserDefaultsKeys: String {
        case accessT
        case refreshT
    }
    
    var accessT: String {
        get {
            userDefaults.string(forKey: UserDefaultsKeys.accessT.rawValue) ?? ""
        }
        set {
            userDefaults.set(newValue, forKey: UserDefaultsKeys.accessT.rawValue)
        }
    }
    
    var refreshT: String {
        get {
            userDefaults.string(forKey: UserDefaultsKeys.refreshT.rawValue) ?? ""
        }
        set {
            userDefaults.set(newValue, forKey: UserDefaultsKeys.refreshT.rawValue)
        }
    }
}
