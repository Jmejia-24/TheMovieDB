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
    var movieDetailSubject: CurrentValueSubject<Movie?, APIError> { get }
}

final class MovieDetailViewModel<R: AppRouter> {
    var router: R?
    
    private var cancellables = Set<AnyCancellable>()
    let movieDetailSubject = CurrentValueSubject<Movie?, APIError>(nil)
    
    private let store: MovieDetailStore
    var movie: Movie
    
    init(movie: Movie ,store: MovieDetailStore = APIManager()) {
        self.movie = movie
        self.store = store
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
}
