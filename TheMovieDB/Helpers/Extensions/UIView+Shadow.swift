//
//  UIView+Shadow.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/23/22.
//

import UIKit

extension UIView {
    func shadow(cornerR: CGFloat = 0, shadowRadius: CGFloat = 3.0, opacity: Float = 1.0) {
        layer.shadowColor = UIColor.black.cgColor
        layer.cornerRadius = cornerR
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = opacity
        layer.shadowOffset = CGSize(width: 4, height: 4)
        layer.masksToBounds = false
    }
    
    func setGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [CGColor(#colorLiteral(red: 0.07223737985, green: 0.1749818623, blue: 0.1992082298, alpha: 1)), UIColor.backgroundView.cgColor]
        gradientLayer.locations = [0, 1]
        gradientLayer.frame = self.layer.bounds
        
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}
