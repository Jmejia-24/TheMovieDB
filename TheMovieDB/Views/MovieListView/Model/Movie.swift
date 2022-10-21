//
//  Movie.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/20/22.
//

import Foundation

struct Movie: Codable, Identifiable {
    let id = UUID().uuidString
    let identifier: Int
    let overview: String
    let posterPath: String
    let releaseDate: String
    let title: String
    let voteAverage: Double
    
    var releaseFormatterDate: Date {
        Self.dateFormatter.date(from: releaseDate) ?? Date()
    }
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case overview
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case title
        case voteAverage = "vote_average"
    }
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

extension Movie: Hashable {
    static func == (lhs: Movie, rhs: Movie) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
}
