//
//  AppStyle.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/23/22.
//

import UIKit

struct AppStyle {
    static func configureAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .navigationColor
        appearance.titleTextAttributes = [.foregroundColor : UIColor.white,
                                          .font : UIFont.boldSystemFont(ofSize: 20)]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = .textColor
        UICollectionView.appearance().backgroundColor = .backgroundView
    }
}
