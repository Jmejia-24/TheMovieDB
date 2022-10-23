//
//  MovieManager.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/22/22.
//

import CoreData
import Combine

struct MovieManager {
    
    let mainContext: NSManagedObjectContext
    
    init(mainContext: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.mainContext = mainContext
    }
}

// MARK: CRUD Implementation

extension MovieManager: Storage {
    
    func fetch<T>() -> Future<[T], StorageFailure> where T : NSManagedObject {
        return Future { promise in
            let fetchRequest = NSFetchRequest<T>(entityName: "MovieEntity")
            
            do {
                let producs = try mainContext.fetch(fetchRequest)
                promise(.success(producs))
            } catch {
                promise(.failure(.error(error)))
            }
        }
    }
    
    func delete<T>(object: T) -> Future<Bool, StorageFailure> {
        return Future { promise in
            guard let movieManagedObject = object as Any as? NSManagedObject else {
                promise(.failure(.storageDataGenel))
                return
            }
            
            mainContext.delete(movieManagedObject)
            
            do {
                try mainContext.save()
                promise(.success(true))
            } catch {
                promise(.failure(.error(error)))
            }
        }
    }
    
    
    func save<T>(object: T) -> Future<Bool, StorageFailure> {
        return Future { promise in
            guard let movie = object as Any as? Movie else {
                promise(.failure(.storageDataSave))
                return
            }
            
            let movieEntity = MovieEntity(context: mainContext)
            
            movieEntity.identifier = Int32(movie.identifier)
            movieEntity.title = movie.title
            movieEntity.posterPath = movie.posterPath
            movieEntity.releaseDate = movie.releaseDate
            movieEntity.overview = movie.overview
            movieEntity.voteAverage = movie.voteAverage
            
            do {
                try mainContext.save()
                promise(.success(true))
            } catch {
                promise(.failure(.error(error)))
            }
        }
    }
}
