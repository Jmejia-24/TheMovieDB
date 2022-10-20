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
    var loginSubject: PassthroughSubject<AutResponse, Failure> { get }
}

final class LoginViewModel<R: AppRouter> {
    var router: R?
    
    private var cancellables = Set<AnyCancellable>()
    let loginSubject = PassthroughSubject<AutResponse, Failure>()
    private let store: LoginStore
    
    private var sccessToken = ""
    
    init(store: LoginStore = APIManager()) {
        self.store = store
    }
}

extension LoginViewModel: LoginViewModelRepresentable {
    func fetchLogin(user: String, password: String) {
        cancellables.removeAll()
        let recievedData = { [unowned self] (response: AutResponse) -> Void in
            DispatchQueue.main.async {
                self.loginSubject.send(response)
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
        
        store.createLogin(username: user, password: password, token: sccessToken)
            .sink(receiveCompletion: completion, receiveValue: recievedData)
            .store(in: &cancellables)
    }
    
    func fetchToken() {
        cancellables.removeAll()
        let recievedData = { [unowned self] (response: AutResponse) -> Void in
            DispatchQueue.main.async {
                self.sccessToken = response.requestToken
            }
        }
        
        let completion = { [unowned self] (completion: Subscribers.Completion<Failure>) -> Void in
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
}
