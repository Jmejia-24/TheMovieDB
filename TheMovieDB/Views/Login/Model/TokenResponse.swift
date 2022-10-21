//
//  TokenResponse.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/19/22.
//

import Foundation

struct TokenResponse: Codable {
    let success: Bool
    let expiresAt: String
    let requestToken: String
    
    enum CodingKeys: String, CodingKey {
        case success
        case expiresAt = "expires_at"
        case requestToken = "request_token"
    }
}
