//
//  ProfileResponse.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/21/22.
//

import Foundation

struct ProfileResponse: Codable {
    let avatar: Avatar?
    let id: Int?
    let name: String?
    let username: String?
}
