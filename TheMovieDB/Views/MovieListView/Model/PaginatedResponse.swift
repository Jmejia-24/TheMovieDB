//
//  PaginatedResponse.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/21/22.
//

import Foundation

struct PaginatedResponse<T: Codable>: Codable {
    let page: Int
    let totalPages: Int
    let totalResults: Int
    let results: [T]
    
    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}
