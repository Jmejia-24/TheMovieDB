//
//  MovieDetailCoordinator.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/21/22.
//

import UIKit

final class MovieDetailCoordinator<R: AppRouter> {
    let router: R
    
    let model: Movie

    init(model: Movie, router: R) {
        self.model = model
        self.router = router
    }
    
    private lazy var primaryViewController: UIViewController = {
        let viewModel = MovieDetailViewModel<R>(movie: model, service: Services(storage: MovieManager()))
        viewModel.router = router
        let viewController = MovieDetailViewController(viewModel: viewModel)
        return viewController
    }()
}

extension MovieDetailCoordinator: Coordinator {
    func start() {
        router.navigationController.pushViewController(primaryViewController, animated: true)
    }
}
