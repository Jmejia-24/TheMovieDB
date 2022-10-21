//
//  MovieListCoordinator.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/20/22.
//

import UIKit

final class MovieListCoordinator<R: AppRouter> {
    
    let router: R

    init(router: R) {
        self.router = router
    }
    
    private lazy var primaryViewController: UIViewController = {
        let viewModel = MovieListViewModel<R>()
        viewModel.router = router
        let viewController = MovieLisViewController(viewModel: viewModel)
        return viewController
    }()
}

extension MovieListCoordinator: Coordinator {
    func start() {
        router.navigationController.pushViewController(primaryViewController, animated: true)
    }
}
