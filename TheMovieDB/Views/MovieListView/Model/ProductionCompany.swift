//
//  ProductionCompany.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/21/22.
//

import Foundation

struct ProductionCompany: Codable, Hashable {
    let id: Int?
    let logoPath: String?
    let name: String?
    let originCountry: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case logoPath = "logo_path"
        case name
        case originCountry = "origin_country"
    }
}
