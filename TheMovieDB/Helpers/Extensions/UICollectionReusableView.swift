//
//  UICollectionReusableView.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/22/22.
//

import UIKit

extension UICollectionReusableView {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}
