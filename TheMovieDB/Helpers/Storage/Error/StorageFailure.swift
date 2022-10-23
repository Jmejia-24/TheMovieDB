//
//  StorageFailure.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/22/22.
//

import Foundation

enum StorageFailure: Error {
    case storageDataSave
    case storageDataDelete
    case storageDataFetch
    case storageDataGenel
    case error(Error)
}
