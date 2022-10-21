//
//  AuthorizationDataManager.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/21/22.
//

import Foundation

protocol AuthorizationDataManagerType {
    func saveAuthorizationSession(sessionId: String)
    func getAuthorizationSession() -> String?
    func saveAuthorizationProfile(model: ProfileResponse)
    func getAuthorizationProfile() -> ProfileResponse?
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
    
    func getAuthorizationSession() -> String? {
        do {
            let sessionId = userDefaults.object(forKey: sessionIdKey)
            return sessionId as? String
        }
    }
    
    func saveAuthorizationProfile(model: ProfileResponse) {
        do {
            try userDefaults.setObject(model, forKey: profileModelKey)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getAuthorizationProfile() -> ProfileResponse? {
        do {
            let model = try userDefaults.getObject(forKey: profileModelKey, castTo: ProfileResponse.self)
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
