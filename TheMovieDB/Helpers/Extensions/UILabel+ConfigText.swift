//
//  UILabel+ConfigText.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/23/22.
//

import UIKit

extension UILabel {
    func configText(lines: Int = 1, color: UIColor = .textColor, sizeFont: CGFloat = 14, alignment: NSTextAlignment = .left) {
        self.numberOfLines = lines
        self.textColor = color
        self.font = .boldSystemFont(ofSize: sizeFont)
        self.textAlignment = alignment
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
