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
}
