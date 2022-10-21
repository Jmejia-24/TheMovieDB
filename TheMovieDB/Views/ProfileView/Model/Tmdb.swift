//
//  Tmdb.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/21/22.
//

import Foundation

struct Tmdb: Codable {
    let avatarPath: String?
    
    enum CodingKeys: String, CodingKey {
        case avatarPath = "avatar_path"
    }
}
