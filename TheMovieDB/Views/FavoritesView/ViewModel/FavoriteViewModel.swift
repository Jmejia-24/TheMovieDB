//
//  FavoriteViewModel.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/22/22.
//

import Combine
import CoreData

protocol FavoriteViewModelRepresentable {
    func loadFavoriteMovies(_ offset: Int)
    func deleteMovie(nsObject: NSManagedObject)
    var favoritesSubject: PassthroughSubject<[MovieObject], StorageFailure> { get }
}

final class FavoriteViewModel<R: AppRouter> {
    weak var router: R?
    private var cancellables = Set<AnyCancellable>()
    let favoritesSubject = PassthroughSubject<[MovieObject], StorageFailure>()
    var store: StorageServices
    
    var movieObjects: [MovieObject]? {
        didSet {
            favoritesSubject.send(movieObjects ?? [])
        }
    }
    
    init(store: StorageServices) {
        self.store = store
    }
}

extension FavoriteViewModel: FavoriteViewModelRepresentable {
    func loadFavoriteMovies(_ offset: Int) {
        let recievedMovies = { (movieManagedObject: [NSManagedObject]) -> Void in
            DispatchQueue.main.async { [unowned self] in
                movieObjects = movieManagedObject.compactMap {
                    MovieObject(nsManagedObject: $0)
                }
            }
        }
        
        let completion = { [unowned self] (completion: Subscribers.Completion<StorageFailure>) -> Void in
            switch  completion {
            case .finished:
                break
            case .failure(let failure):
                favoritesSubject.send(completion: .failure(.error(failure)))
            }
        }
        
        store.fetch()
            .sink(receiveCompletion: completion, receiveValue: recievedMovies)
            .store(in: &cancellables)
    }
    
    func deleteMovie(nsObject: NSManagedObject) {
        let completion = { [unowned self] (completion: Subscribers.Completion<StorageFailure>) -> Void in
            switch  completion {
            case .finished:
                break
            case .failure(let failure):
                favoritesSubject.send(completion: .failure(.error(failure)))
            }
        }
        
        store.delete(movieManagedObject: nsObject)
            .sink(receiveCompletion: completion, receiveValue: { (response: Bool) -> Void in })
            .store(in: &cancellables)
    }
}
