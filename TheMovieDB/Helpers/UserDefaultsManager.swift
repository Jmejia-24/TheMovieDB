//
//  UserDefaultsManager.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/21/22.
//

import Foundation

public enum StorageKey: String {
    case isAuthenticationAccepted
    case username
    case password
}

public protocol UserDefaultsManagerProtocol: AnyObject {
    var isAuthenticationAccepted: Bool { get set }
    var username: String { get set }
    var password: String { get set }
}

public final class UserDefaultsManager: UserDefaultsManagerProtocol {
    
    public static let shared = UserDefaultsManager()
    
    private let defaults = UserDefaults.standard
    
    public var isAuthenticationAccepted: Bool {
        get {
            defaults.bool(forKey: StorageKey.isAuthenticationAccepted.rawValue)
        }
        set(value) {
            defaults.set(value, forKey: StorageKey.isAuthenticationAccepted.rawValue)
        }
    }
    
    public var username: String {
        get {
            defaults.string(forKey: StorageKey.username.rawValue) ?? ""
        }
        set(value) {
            defaults.set(value, forKey: StorageKey.username.rawValue)
        }
    }
    
    public var password: String {
        get {
            defaults.string(forKey: StorageKey.password.rawValue) ?? ""
        }
        set(value) {
            defaults.set(value, forKey: StorageKey.password.rawValue)
        }
    }
}
