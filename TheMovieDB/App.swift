//
//  App.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/19/22.
//

import UIKit

final class App {
    var navigationController = UINavigationController()
    private var coordinatorRegister: [AppTransition: Coordinator] = [:]
}

extension App: Coordinator {
    func start() {
        process(route: .showMainScreen)
    }
}

extension App: AppRouter {
    
    func exit() {
        /// In this Router context - the only exit left is the main screen.
        /// Logout - clean tokens - local cache - offline database if needed etc.
        
        AuthorizationDataManager.shared.clearAuthorization()
        navigationController.popToRootViewController(animated: true)
    }
    
    func process(route: AppTransition) {
        print("Processing route: \(route)")
        let coordinator = route.hasState ? coordinatorRegister[route] : route.coordinatorFor(router: self)
        coordinator?.start()
    }
}
