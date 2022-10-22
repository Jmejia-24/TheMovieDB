//
//  LoginViewController.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/19/22.
//

import UIKit
import Combine

final class LoginViewController: UIViewController {
    private let viewModel: LoginViewModelRepresentable
    private var subscription: AnyCancellable?
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.center = view.center
        return indicator
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "star.fill")
        imageView.image = #imageLiteral(resourceName: "icon-default")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var userNameTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Username"
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var loginButton: UIButton = {
        let action = UIAction { [unowned self] _ in
            guard let userName = userNameTextField.text,
                  let password = passwordTextField.text,
                  !userName.isEmpty,
                  !password.isEmpty else {
                showError(errorMessage: "Required fields")
                return }
            
            if !errorLabel.isHidden {
                errorLabel.isHidden = true
            }
            
            activityIndicator.startAnimating()
            
            clearTextField()
            viewModel.fetchLogin(user: userName, password: password)
            
        }
        let button = UIButton(configuration: .gray(), primaryAction: action)
        button.setTitle("Login", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private func clearTextField() {
        passwordTextField.text = ""
        userNameTextField.text = ""
    }
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "Erro"
        label.textColor = .red
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 14.0)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var containerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView,
                                                       userNameTextField,
                                                       passwordTextField,
                                                       loginButton,
                                                       errorLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    init(viewModel: LoginViewModelRepresentable) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bindUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if activityIndicator.isAnimating {
            activityIndicator.stopAnimating()
        }
    }
    
    private func setUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(containerStackView)
        view.addSubview(activityIndicator)
        viewModel.fetchToken()
        setupConstraints()
    }
    
    private func bindUI() {
        subscription = viewModel.loginSubject.sink { [unowned self] completion in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                DispatchQueue.main.async { [unowned self] in
                    activityIndicator.stopAnimating()
                    showError(errorMessage: error.message)
                }
            }
        } receiveValue: { [unowned self] response in
            viewModel.goToMainScreen()
        }
    }
    
    private func showError(errorMessage: String) {
        errorLabel.isHidden = false
        errorLabel.text = errorMessage
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            containerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            imageView.heightAnchor.constraint(equalToConstant: 150),
            imageView.widthAnchor.constraint(equalToConstant: 150)
        ])
        
        [userNameTextField, passwordTextField, loginButton, errorLabel].forEach { view in
            NSLayoutConstraint.activate([
                view.widthAnchor.constraint(equalTo: containerStackView.widthAnchor)
            ])
        }
    }
}
