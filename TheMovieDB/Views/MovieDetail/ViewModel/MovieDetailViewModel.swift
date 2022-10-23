//
//  MovieDetailViewModel.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/21/22.
//

import UIKit
import Combine

protocol MovieDetailViewModelRepresentable {
    func fetchMovieDetail()
    func saveToFavorite()
    var movie: Movie { get set }
    var movieDetailSubject: CurrentValueSubject<Movie?, APIError> { get }
}

final class MovieDetailViewModel<R: AppRouter> {
    var router: R?
    
    private var cancellables = Set<AnyCancellable>()
    let movieDetailSubject = CurrentValueSubject<Movie?, APIError>(nil)
    
    private var service: StorageServices
    private let store: MovieDetailStore
    var movie: Movie
    
    init(movie: Movie , store: MovieDetailStore = APIManager(), service: StorageServices) {
        self.movie = movie
        self.store = store
        self.service = service
    }
}

extension MovieDetailViewModel: MovieDetailViewModelRepresentable {
    func fetchMovieDetail() {
        let recievedDetail = { (response: Movie) -> Void in
            DispatchQueue.main.async { [unowned self] in
                movieDetailSubject.send(response)
            }
        }
        
        let completion = { [unowned self] (completion: Subscribers.Completion<APIError>) -> Void in
            switch  completion {
            case .finished:
                break
            case .failure(let failure):
                movieDetailSubject.send(completion: .failure(failure))
            }
        }
        
        store.getMovieDetail(for: movie.identifier)
            .sink(receiveCompletion: completion, receiveValue: recievedDetail)
            .store(in: &cancellables)
    }
    
    func saveToFavorite() {
        
        let recievedValue = { (response: Bool) -> Void in
            print("Is Save \(response)")
        }
        
        let completion = { (completion: Subscribers.Completion<StorageFailure>) -> Void in
            switch  completion {
            case .finished:
                break
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
        
        service.save(movie: movie)
            .sink(receiveCompletion: completion, receiveValue: recievedValue)
            .store(in: &cancellables)
    }
}
