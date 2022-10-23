//
//  AuthorizationDataManager.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/21/22.
//

import Foundation

protocol AuthorizationDataManagerType {
    func saveAuthorizationSession(sessionId: String)
    var getAuthorizationSession: String? { get }
    func saveAuthorizationProfile(model: Profile)
    var getAuthorizationProfile: Profile? { get }
    func clearAuthorization()
}

final class AuthorizationDataManager: AuthorizationDataManagerType {
    
    static let shared = AuthorizationDataManager()
    private let sessionIdKey = "sessionId"
    private let profileModelKey = "profileModelKey"
    private let userDefaults = UserDefaults.standard
    
    func saveAuthorizationSession(sessionId: String) {
        do {
            userDefaults.set(sessionId, forKey: sessionIdKey)
        }
    }
    
    var getAuthorizationSession: String? {
        do {
            let sessionId = userDefaults.object(forKey: sessionIdKey)
            return sessionId as? String
        }
    }
    
    func saveAuthorizationProfile(model: Profile) {
        do {
            try userDefaults.setObject(model, forKey: profileModelKey)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    var getAuthorizationProfile: Profile? {
        do {
            let model = try userDefaults.getObject(forKey: profileModelKey, castTo: Profile.self)
            return model
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func clearAuthorization() {
        userDefaults.removeObject(forKey: sessionIdKey)
    }
}
