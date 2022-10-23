//
//  FavoriteCoordinator.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/22/22.
//

import UIKit

final class FavoriteCoordinator<R: AppRouter> {
    
    let router: R

    init(router: R) {
        self.router = router
    }
    
    private lazy var primaryViewController: UIViewController = {
        let viewModel = FavoriteViewModel<R>(store: Services(storage: MovieManager()))
        viewModel.router = router
        let viewController = FavoriteViewController(viewModel: viewModel)
        return viewController
    }()
}

extension FavoriteCoordinator: Coordinator {
    func start() {
        router.navigationController.pushViewController(primaryViewController, animated: true)
    }
}
