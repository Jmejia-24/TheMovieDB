//
//  ErrorModel.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/21/22.
//

import Foundation

struct ErrorModel: Codable {
    var message: String
    
    enum CodingKeys: String, CodingKey {
        case message = "status_message"
    }
}
