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
    private var subscriptionError: AnyCancellable?
    private var subscriptionSucces: AnyCancellable?
    
    private var cancellables = Set<AnyCancellable>()
    
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
            didTapLoginButton()
        }
        let button = UIButton(primaryAction: action)
        button.setTitle("Login", for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.84881109, green: 0.8388829827, blue: 0.8131651878, alpha: 1)
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
        label.configText(lines: 0, color: .errorColor)
        return label
    }()
    
    private lazy var containerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView,
                                                       userNameTextField,
                                                       passwordTextField,
                                                       loginButton])
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
        navigationController?.isNavigationBarHidden = true
        if activityIndicator.isAnimating {
            activityIndicator.stopAnimating()
        }
        viewModel.fetchToken()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    private func setUI() {
        navigationController?.isNavigationBarHidden = true
        view.setGradientBackground()
        view.addSubview(containerStackView)
        view.addSubview(activityIndicator)
        view.addSubview(errorLabel)
        setupConstraints()
    }
    
    private func bindUI() {
        subscriptionSucces = viewModel.loginSubject.sink { _ in
        } receiveValue: { response in
            DispatchQueue.main.async { [unowned self] in
                if activityIndicator.isAnimating {
                    activityIndicator.stopAnimating()
                }
            }
        }
        
        subscriptionError = viewModel.errorSubject.sink { _ in
        } receiveValue: { errorResponse in
            DispatchQueue.main.async { [unowned self] in
                if activityIndicator.isAnimating {
                    activityIndicator.stopAnimating()
                }
                showError(errorMessage: errorResponse.message)
            }
        }
    }
    
    private func didTapLoginButton() {
        guard let userName = userNameTextField.text,
              let password = passwordTextField.text,
              !userName.isEmpty,
              !password.isEmpty
        else {
            showError(errorMessage: "Required fields")
            return
        }
        
        if !errorLabel.isHidden {
            errorLabel.isHidden = true
        }
        
        activityIndicator.startAnimating()
        
        clearTextField()
        viewModel.fetchLogin(user: userName, password: password)
        
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
            imageView.widthAnchor.constraint(equalToConstant: 150),
            
            errorLabel.heightAnchor.constraint(equalToConstant: 50),
            errorLabel.topAnchor.constraint(equalTo: containerStackView.bottomAnchor, constant: 10),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
        ])
        
        [userNameTextField, passwordTextField, loginButton].forEach { view in
            NSLayoutConstraint.activate([
                view.widthAnchor.constraint(equalTo: containerStackView.widthAnchor),
                view.heightAnchor.constraint(equalToConstant: 50)
            ])
        }
    }
}
