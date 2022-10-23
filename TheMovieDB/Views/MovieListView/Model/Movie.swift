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
    let backdropPath: String?
    let posterPath: String?
    let releaseDate: String
    let title: String
    let voteAverage: Double
    let productionCompanies: [ProductionCompany]?
    let popularity: Double
    let genres: [Genre]?
    
    var isFavorite: Bool {
        get {
            UserDefaultsManager.shared.getIsMovieFavorite(forKey: "\(identifier)-favorite")
        }
        set {
            UserDefaultsManager.shared.setIsMovieFavorite(value: newValue, forKey: "\(identifier)-favorite")
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case overview
        case backdropPath = "backdrop_path"
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case title
        case voteAverage = "vote_average"
        case productionCompanies = "production_companies"
        case popularity
        case genres
    }
}

extension Movie: Hashable {
    static func == (lhs: Movie, rhs: Movie) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
}
