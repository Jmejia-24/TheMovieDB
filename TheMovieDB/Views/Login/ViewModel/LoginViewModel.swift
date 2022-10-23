//
//  LoginViewModel.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/19/22.
//

import UIKit
import Combine

protocol LoginViewModelRepresentable {
    func fetchToken()
    func fetchLogin(user: String, password: String)
    func goToMainScreen()
    var loginSubject: PassthroughSubject<TokenResponse, Error> { get }
    var errorSubject: PassthroughSubject<APIError, Error> { get }
}

final class LoginViewModel<R: AppRouter> {
    var router: R?
    
    private var cancellables = Set<AnyCancellable>()
    let loginSubject = PassthroughSubject<TokenResponse, Error>()
    let errorSubject = PassthroughSubject<APIError, Error>()
    
    private let store: LoginStore
    private var tokenResponse: TokenResponse?
    
    private var isAuthenticationAccepted: Bool {
        UserDefaultsManager.shared.isAuthenticationAccepted
    }
    
    init(store: LoginStore = APIManager()) {
        self.store = store
    }
    
}

extension LoginViewModel: LoginViewModelRepresentable {
    
    func fetchToken() {
        cancellables.removeAll()
        
        let recievedData = { (response: TokenResponse) -> Void in
            DispatchQueue.main.async { [unowned self] in
                tokenResponse = response
                if !isAuthenticationAccepted {
                    UserDefaultsManager.shared.isAuthenticationAccepted = true
                }
            }
        }
        
        store.createToken()
            .sink(receiveCompletion: { _ in }, receiveValue: recievedData)
            .store(in: &cancellables)
    }
    
    func fetchLogin(user: String, password: String) {
        guard let requestToken = tokenResponse?.requestToken else { return }
        cancellables.removeAll()
        
        UserDefaultsManager.shared.username = user
        UserDefaultsManager.shared.password = password
        
        let recievedData = { (response: TokenResponse) -> Void in
            DispatchQueue.main.async { [unowned self] in
                tokenResponse = response
                fetchSession()
                loginSubject.send(response)
                if response.success {
                    goToMainScreen()
                }
            }
        }
        
        let completion = { [unowned self] (completion: Subscribers.Completion<APIError>) -> Void in
            switch  completion {
            case .finished:
                break
            case .failure(let failure):
                errorSubject.send(failure)
            }
        }
        
        store.login(username: user, password: password, token: requestToken)
            .sink(receiveCompletion: completion, receiveValue: recievedData)
            .store(in: &cancellables)
    }
    
    func fetchSession() {
        guard let requestToken = tokenResponse?.requestToken else { return }
        cancellables.removeAll()
        
        let recievedData = { (response: CreateSessionResponse) -> Void in
            DispatchQueue.main.async { [unowned self] in
                guard let sessionId = response.sessionID else { return }
                
                AuthorizationDataManager.shared.saveAuthorizationSession(sessionId: sessionId)
                fetchAccountDetails()
            }
        }
        
        store.createSession(requestToken: requestToken)
            .sink(receiveCompletion: { _ in }, receiveValue: recievedData)
            .store(in: &cancellables)
    }
    
    func fetchAccountDetails() {
        guard let sessionId = AuthorizationDataManager.shared.getAuthorizationSession else { return }
        cancellables.removeAll()
        
        let recievedAccountDetails = { (response: Profile) -> Void in
            DispatchQueue.main.async {
                AuthorizationDataManager.shared.saveAuthorizationProfile(model: response)
            }
        }
        
        store.getAccountDetails(sessionId: sessionId)
            .sink(receiveCompletion: { _ in }, receiveValue: recievedAccountDetails)
            .store(in: &cancellables)
    }
    
    func goToMainScreen() {
        router?.process(route: .showMainScreen)
    }
}
