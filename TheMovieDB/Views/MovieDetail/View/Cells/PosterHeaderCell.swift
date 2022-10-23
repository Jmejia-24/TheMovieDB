//
//  PosterHeaderCell.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/21/22.
//

import UIKit

final class PosterHeaderCell: UICollectionViewCell {
    
    private var movieImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "PosterPlaceholder")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var label: UILabel = {
        let label = UILabel()
        label.configText(lines: 2, color: .white, sizeFont: 28)
        label.adjustsFontForContentSizeCategory = true
        label.shadow()
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUI() {
        addSubview(movieImageView)
        addSubview(label)
        shadow()
    }
    
    private func setupConstraint() {
        NSLayoutConstraint.activate([
            movieImageView.bottomAnchor.constraint(equalTo:  safeAreaLayoutGuide.bottomAnchor),
            movieImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            movieImageView.widthAnchor.constraint(equalTo: widthAnchor),
            
            label.bottomAnchor.constraint(equalTo: movieImageView.bottomAnchor, constant: -10),
            label.leadingAnchor.constraint(equalTo: movieImageView.leadingAnchor,constant: 15),
            label.trailingAnchor.constraint(equalTo: movieImageView.trailingAnchor,constant: -15)
        ])
    }
    
    func configCell(_ movie: Movie) {
        label.text = movie.title
        
        Task {
            movieImageView.image = await ImageCacheStore.shared.getCacheImage(for: movie.backdropPath)
        }
    }
}
