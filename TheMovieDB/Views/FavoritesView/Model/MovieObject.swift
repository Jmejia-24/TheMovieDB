//
//  MovieObject.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/22/22.
//

import CoreData

struct MovieObject: Hashable {
    private var _productNSManagedObject: NSManagedObject!
    var movie: Movie?
    
    var productNSManagedObject: NSManagedObject {
        set {
            _productNSManagedObject = newValue
            fillMovieModel(from: newValue)
        }
        get { _productNSManagedObject }
    }
    
    private mutating func fillMovieModel(from nsManagedObj: NSManagedObject) {
        
        if let identifier = nsManagedObj.value(forKey: "identifier") as? Int32,
           let title = nsManagedObj.value(forKey: "title") as? String,
           let overview = nsManagedObj.value(forKey: "overview") as? String,
           let posterPath = nsManagedObj.value(forKey: "posterPath") as? String,
           let releaseDate = nsManagedObj.value(forKey: "releaseDate") as? String,
           let voteAverage = nsManagedObj.value(forKey: "voteAverage") as? Double {
            
            movie = Movie(identifier: Int(identifier),
                          overview: overview,
                          backdropPath: nil,
                          posterPath: posterPath,
                          releaseDate: releaseDate,
                          title: title,
                          voteAverage: voteAverage,
                          productionCompanies: nil)
        }
    }
    
    init(nsManagedObject: NSManagedObject) {
        self.productNSManagedObject = nsManagedObject
    }
}
