//
//  MovieListViewModel.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/20/22.
//

import UIKit
import Combine

protocol ListViewModelRepresentable {
    func prefetchData(for indexPaths: [IndexPath])
    func didTapItem(model: Movie)
    func fetchMovies(_ offset: Int)
    func logOut()
    func goToProfile()
    var moviesType: MoviesType { get set }
    var movieListSubject: PassthroughSubject<[Movie], Failure> { get }
}

final class MovieListViewModel<R: AppRouter> {
    var router: R?
    let movieListSubject = PassthroughSubject<[Movie], Failure>()
    
    private var cancellables = Set<AnyCancellable>()
    private let store: MovieListStore
    
    var moviesType = MoviesType.popular
    
    private var fetchedMovies = [Movie]() {
        didSet {
            movieListSubject.send(fetchedMovies)
        }
    }
    
    init(store: MovieListStore = APIManager()) {
        self.store = store
    }
}

extension MovieListViewModel: ListViewModelRepresentable {
    func prefetchData(for indexPaths: [IndexPath]) {
        guard let index = indexPaths.last?.row else { return }

        let movieAlreadyLoaded = fetchedMovies.count
        if index > movieAlreadyLoaded - 10 {
            fetchMovies(movieAlreadyLoaded)
        }
    }
    
    func didTapItem(model: Movie) {
        
    }
    
    func fetchMovies(_ offset: Int) {
        let recievedMovies = { [unowned self] (response: PaginatedResponse<Movie>) -> Void in
            DispatchQueue.main.async {
                self.fetchedMovies.append(contentsOf: response.results)
            }
        }
        
        let completion = { [unowned self] (completion: Subscribers.Completion<Failure>) -> Void in
            switch  completion {
            case .finished:
                break
            case .failure(let failure):
                movieListSubject.send(completion: .failure(failure))
            }
        }
        
        store.getMoviesList(for: moviesType.rawValue, with: offset)
            .sink(receiveCompletion: completion, receiveValue: recievedMovies)
            .store(in: &cancellables)
    }
    
    func logOut() {
        router?.exit()
    }
    
    func goToProfile() {
        router?.process(route: .showProfile)
    }
}
