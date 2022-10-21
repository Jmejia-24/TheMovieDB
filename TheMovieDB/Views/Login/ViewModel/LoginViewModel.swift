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
    var loginSubject: PassthroughSubject<TokenResponse, Failure> { get }
}

final class LoginViewModel<R: AppRouter> {
    var router: R?
    
    private var cancellables = Set<AnyCancellable>()
    let loginSubject = PassthroughSubject<TokenResponse, Failure>()
    
    private let store: LoginStore
    
    private var tokenResponse: TokenResponse?
    
    private var isAuthenticationAccepted: Bool {
        UserDefaultsManager.shared.isAuthenticationAccepted
    }
    
    init(store: LoginStore = APIManager()) {
        self.store = store
    }
    
    func saveSessionId(sessionId: String) {
        AuthorizationDataManager.shared.saveAuthorizationSession(sessionId: sessionId)
    }
    
    func saveAuthorizationProfile(model: Profile) {
        AuthorizationDataManager.shared.saveAuthorizationProfile(model: model)
    }
}

extension LoginViewModel: LoginViewModelRepresentable {
    
    func fetchToken() {
        cancellables.removeAll()
        let recievedData = { [unowned self] (response: TokenResponse) -> Void in
            DispatchQueue.main.async {
                self.tokenResponse = response
                
                if !self.isAuthenticationAccepted {
                    UserDefaultsManager.shared.isAuthenticationAccepted = true
                }
            }
        }
        
        let completion = { (completion: Subscribers.Completion<Failure>) -> Void in
            switch  completion {
            case .finished:
                break
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
        
        store.createToken()
            .sink(receiveCompletion: completion, receiveValue: recievedData)
            .store(in: &cancellables)
    }
    
    func fetchLogin(user: String, password: String) {
        cancellables.removeAll()
        guard let requestToken = tokenResponse?.requestToken else { return }
        
        UserDefaultsManager.shared.username = user
        UserDefaultsManager.shared.password = password
        
        let recievedData = { [unowned self] (response: TokenResponse) -> Void in
            DispatchQueue.main.async {
                self.tokenResponse = response
                self.loginSubject.send(response)
                self.fetchSession()
            }
        }
        
        let completion = { [unowned self] (completion: Subscribers.Completion<Failure>) -> Void in
            switch  completion {
            case .finished:
                break
            case .failure(let failure):
                loginSubject.send(completion: .failure(failure))
            }
        }
        
        store.login(username: user, password: password, token: requestToken)
            .sink(receiveCompletion: completion, receiveValue: recievedData)
            .store(in: &cancellables)
    }
    
    func fetchSession() {
        cancellables.removeAll()
        guard let requestToken = tokenResponse?.requestToken else { return }
        
        let recievedData = { [unowned self] (response: CreateSessionResponse) -> Void in
            DispatchQueue.main.async {
                guard let sessionId = response.sessionID else { return }
                
                self.saveSessionId(sessionId: sessionId)
                self.fetchAccountDetails()
            }
        }
        
        let completion = { (completion: Subscribers.Completion<Failure>) -> Void in
            switch  completion {
            case .finished:
                break
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
        
        store.createSession(requestToken: requestToken)
            .sink(receiveCompletion: completion, receiveValue: recievedData)
            .store(in: &cancellables)
    }
    
    func fetchAccountDetails() {
        cancellables.removeAll()
        guard let sessionId = AuthorizationDataManager.shared.getAuthorizationSession else { return }
        
        let recievedAccountDetails = { [unowned self] (response: Profile) -> Void in
            DispatchQueue.main.async {
                self.saveAuthorizationProfile(model: response)
            }
        }
        
        let completion = { (completion: Subscribers.Completion<Failure>) -> Void in
            switch  completion {
            case .finished:
                break
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
        
        store.getAccountDetails(sessionId: sessionId)
            .sink(receiveCompletion: completion, receiveValue: recievedAccountDetails)
            .store(in: &cancellables)
    }
    
    func goToMainScreen() {
        router?.process(route: .showMainScreen)
    }
}
