//
//  ProfileViewModel.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/20/22.
//

import UIKit
import Combine

protocol ProfileViewModelRepresentable {
    func getAccountDetails()
    var profileItem: Profile? { get }
    var favoritesSubject: PassthroughSubject<[Movie], Failure> { get }
}

final class ProfileViewModel<R: AppRouter> {
    weak var router: R?
    
    let favoritesSubject = PassthroughSubject<[Movie], Failure>()
    var profileItem: Profile?
    
    private var cancellables = Set<AnyCancellable>()

}

extension ProfileViewModel: ProfileViewModelRepresentable {
    
    func getAccountDetails() {
        guard AuthorizationDataManager.shared.getAuthorizationSession != nil,
              let profile = AuthorizationDataManager.shared.getAuthorizationProfile
        else { return }
        profileItem = profile
        favoritesSubject.send([])
    }
}
