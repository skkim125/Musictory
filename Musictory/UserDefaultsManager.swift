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
        case userID
        case accessT
        case refreshT
        case email
        case password
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
    
    var email: String {
        get {
            userDefaults.string(forKey: UserDefaultsKeys.email.rawValue) ?? ""
        }
        set {
            userDefaults.set(newValue, forKey: UserDefaultsKeys.email.rawValue)
        }
    }
    
    var password: String {
        get {
            userDefaults.string(forKey: UserDefaultsKeys.password.rawValue) ?? ""
        }
        set {
            userDefaults.set(newValue, forKey: UserDefaultsKeys.password.rawValue)
        }
    }
    
    var userID: String {
        get {
            userDefaults.string(forKey: UserDefaultsKeys.userID.rawValue) ?? ""
        }
        set {
            userDefaults.set(newValue, forKey: UserDefaultsKeys.userID.rawValue)
        }
    }
}
