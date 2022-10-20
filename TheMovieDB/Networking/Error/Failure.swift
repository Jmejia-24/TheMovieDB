//
//  Failure.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/19/22.
//

import Foundation

enum Failure: Error {
    case decodingError
    case urlConstructError
    case APIError(Error)
    case statusCode
}
