//
//  LoginCoordinator.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/19/22.
//

import UIKit

final class LoginCoordinator<R: AppRouter> {
    let router: R
    
    private lazy var primaryViewController: UIViewController = {
        let viewModel = LoginViewModel<R>()
        viewModel.router = router
        let viewController = LoginViewController(viewModel: viewModel)
        return viewController
    }()
    
    init(router: R) {
        self.router = router
    }
}

extension LoginCoordinator: Coordinator {
    func start() {
        router.navigationController.pushViewController(primaryViewController, animated: false)
    }
}
