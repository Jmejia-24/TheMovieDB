//
//  Storage.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/22/22.
//

import CoreData
import Combine

protocol Storage {
    func save<T>(object: T) -> Future<Bool, StorageFailure>
    func delete<T>(object: T)  -> Future<Bool, StorageFailure>
    func fetch<T: NSManagedObject>() -> Future<[T], StorageFailure>
}
