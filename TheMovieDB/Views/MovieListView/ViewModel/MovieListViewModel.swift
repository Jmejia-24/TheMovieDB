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
    func fetchMovies(isPrefetch: Bool, offset: Int)
    func logOut()
    func goToProfile()
    func goToFavorite()
    var currentListMovie: MovieType { get set }
    var movieListSubject: CurrentValueSubject<[Movie], APIError> { get }
}

final class MovieListViewModel<R: AppRouter> {
    var router: R?
    let movieListSubject = CurrentValueSubject<[Movie], APIError>([])
    
    private var cancellables = Set<AnyCancellable>()
    private let store: MovieListStore
    
    var currentListMovie = MovieType.popular {
        didSet {
            fetchMovies(isPrefetch: false, offset: 1)
        }
    }
    
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
            fetchMovies(offset: movieAlreadyLoaded)
        }
    }
    
    func didTapItem(model: Movie) {
        router?.process(route: .showDetail(model: model))
    }
    
    func fetchMovies(isPrefetch: Bool = true, offset: Int) {
        let recievedMovies = { (response: PaginatedResponse<Movie>) -> Void in
            DispatchQueue.main.async { [unowned self] in
                
                if !isPrefetch {
                    fetchedMovies.removeAll()
                }
                
                fetchedMovies.append(contentsOf: response.results)
            }
        }
        
        let completion = { [unowned self] (completion: Subscribers.Completion<APIError>) -> Void in
            switch  completion {
            case .finished:
                break
            case .failure(let failure):
                movieListSubject.send(completion: .failure(failure))
            }
        }
        
        store.getMoviesList(for: currentListMovie.rawValue, with: offset)
            .sink(receiveCompletion: completion, receiveValue: recievedMovies)
            .store(in: &cancellables)
    }
    
    func logOut() {
        router?.exit()
    }
    
    func goToProfile() {
        router?.process(route: .showProfile)
    }
    
    func goToFavorite() {
        router?.process(route: .showFavorite)
    }
}
