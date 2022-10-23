//
//  AppTransition.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/19/22.
//

import Foundation

enum AppTransition {
    
    case showLogin
    case showMainScreen
    case showProfile
    case showDetail(model: Movie)
    case showFavorite
    
    var hasState: Bool {
        /// If some transitions need to have state - perform case match logic here
        /// Generally prefer stateless
        false
    }
    
    func coordinatorFor<R: AppRouter>(router: R) -> Coordinator {
        switch self {
        case .showLogin: return LoginCoordinator(router: router)
        case .showMainScreen: return MovieListCoordinator(router: router)
        case .showProfile: return ProfileCoordinator(router: router)
        case .showDetail(let model): return MovieDetailCoordinator(model: model, router: router)
        case .showFavorite: return FavoriteCoordinator(router: router)
        }
    }
}

extension AppTransition: Hashable {
    
    var identifier: String {
        switch self {
        case .showLogin: return "showLogin"
        case .showMainScreen: return "showMainScreen"
        case .showProfile: return "showProfile"
        case .showDetail: return "showDetail"
        case .showFavorite: return "showFavorite"
        }
    }
    
    static func == (lhs: AppTransition, rhs: AppTransition) -> Bool {
        lhs.identifier == rhs.identifier
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
