//
//  ProfileCoordinator.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/21/22.
//

import UIKit

final class ProfileCoordinator<R: AppRouter> {
    
    let router: R
    
    init(router: R) {
        self.router = router
    }
    
    private lazy var primaryViewController: UIViewController = {
        let viewModel = ProfileViewModel<R>()
        viewModel.router = router
        let viewController = ProfileViewController(viewModel: viewModel)
        return viewController
    }()
}

extension ProfileCoordinator: Coordinator {
    func start() {
        router.navigationController.pushViewController(primaryViewController,
                                                       animated: true)
    }
}
