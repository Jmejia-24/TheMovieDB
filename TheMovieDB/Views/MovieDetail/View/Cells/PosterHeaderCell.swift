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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setUI() {
        backgroundColor = .gray
        addSubview(movieImageView)
    }
    
    private func setupConstraint() {
        NSLayoutConstraint.activate([
            movieImageView.bottomAnchor.constraint(equalTo:  safeAreaLayoutGuide.bottomAnchor),
            movieImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            movieImageView.widthAnchor.constraint(equalTo: widthAnchor)
        ])
    }
    
    func configCell(_ movie: Movie) {
//        movieTitle.text = movie.title
//        dateLabel.text = movie.releaseDate.printFormattedDate()
//        ratingLabel.text =  "\u{2B50} \(movie.voteAverage) "
//        descriptionLabel.text = movie.overview
//
        Task {
            movieImageView.image = await ImageCacheStore.shared.getCacheImage(for: movie.backdropPath)
        }
    }
}
