//
//  Profile.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/21/22.
//

import Foundation

struct Profile: Codable {
    let avatar: Avatar?
    let id: Int?
    let name: String?
    let username: String?
}

extension Profile: Hashable {
    static func == (lhs: Profile, rhs: Profile) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
}
