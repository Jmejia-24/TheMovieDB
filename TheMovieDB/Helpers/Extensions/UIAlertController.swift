//
//  UIAlertController.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/20/22.
//

import UIKit

extension UIAlertController {
    
    final class Builder {
        
        private var title: String?
        private var message: String?
        private var actions: [UIAlertAction] = []
        private var alertStyle: UIAlertController.Style = .alert
        private var showTextField = false
        
        public var textFields: [UITextField]?
        
        @discardableResult func withTitle(_ title: String?) -> Builder {
            self.title = title
            return self
        }
        
        @discardableResult func withMessage(_ message: String?) -> Builder {
            self.message = message
            return self
        }
        
        @discardableResult func withButton(style: UIAlertAction.Style = .default,
                                           title: String,
                                           callback: ((Builder) -> Void)? = nil) -> Builder {
            
            let cancelAction = UIAlertAction(title: title,
                                             style: style,
                                             handler: { _ in callback?(self) })
            
            actions.append(cancelAction)
            return self
        }
        
        @discardableResult func withAlertStyle(_ style: UIAlertController.Style) -> Builder {
            self.alertStyle = style
            return self
        }
        
        @discardableResult func withTextField(_ showTextField: Bool) -> Builder {
            self.showTextField = showTextField
            return self
        }
        
        func present(in viewController: UIViewController) {
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self, viewController.isViewLoaded, viewController.view.window != nil else { return }
                let alert = UIAlertController(title: self.title, message: self.message, preferredStyle: self.alertStyle)
                if self.showTextField {
                    alert.addTextField()
                    self.textFields = alert.textFields
                }
                
                self.actions.forEach { alert.addAction($0) }
                viewController.present(alert, animated: true)
            }
        }
    }
}

extension UIViewController {
    func presentErrorAlert(for errorCode: Int = 0, with error: String) {
        UIAlertController
            .Builder()
            .withTitle(NSLocalizedString("Error \(errorCode)", comment: "Error title shown in modal"))
            .withMessage(error)
            .withButton(title: NSLocalizedString("OK", comment: "OK Button title shown in modal"))
            .present(in: self)
    }
}

