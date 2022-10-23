//
//  MovieViewCell.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/20/22.
//

import UIKit

final class MoviesViewCell: UICollectionViewCell {
    
    private var movieImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "MoviePlaceholder")
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var movieTitle: UILabel = {
        let title = UILabel()
        title.numberOfLines = 1
        title.font = .preferredFont(forTextStyle: .headline)
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    private var dateLabel: UILabel = {
        let date = UILabel()
        date.numberOfLines = 1
        date.font = .boldSystemFont(ofSize: 16)
        date.translatesAutoresizingMaskIntoConstraints = false
        return date
    }()
    
    private var ratingLabel: UILabel = {
        let rating = UILabel()
        rating.numberOfLines = 1
        rating.font = .boldSystemFont(ofSize: 16)
        rating.translatesAutoresizingMaskIntoConstraints = false
        rating.textAlignment = .right
        return rating
    }()
    
    private var descriptionLabel: UILabel = {
        let description = UILabel()
        description.numberOfLines = 0
        description.textAlignment = .left
        description.font = .boldSystemFont(ofSize: 14)
        description.translatesAutoresizingMaskIntoConstraints = false
        return description
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [movieTitle, secondStackView, descriptionLabel])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var secondStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [dateLabel, ratingLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
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
        layer.cornerRadius = 20
        backgroundColor = .systemCyan
        addSubview(movieImageView)
        addSubview(stackView)
    }
    
    private func setupConstraint() {
        NSLayoutConstraint.activate([
            movieImageView.heightAnchor.constraint(equalToConstant: 200),
            movieImageView.topAnchor.constraint(equalTo: topAnchor),
            movieImageView.widthAnchor.constraint(equalTo: widthAnchor),
            
            stackView.topAnchor.constraint(equalTo: movieImageView.bottomAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
        ])
    }
    
    func configCell(_ movie: Movie) {
        movieTitle.text = movie.title
        dateLabel.text = movie.releaseDate.printFormattedDate()
        ratingLabel.text =  "\u{2B50} \(movie.voteAverage) "
        descriptionLabel.text = movie.overview
        
        Task {
            movieImageView.image = await ImageCacheStore.shared.getCacheImage(for: movie.posterPath)
        }
    }
    
    func configCell(movieObject: MovieObject) {
        guard let movie = movieObject.movie else { return }
        movieTitle.text = movie.title
        dateLabel.text = movie.releaseDate.printFormattedDate()
        ratingLabel.text =  "\u{2B50} \(movie.voteAverage) "
        descriptionLabel.text = movie.overview
        
        Task {
            movieImageView.image = await ImageCacheStore.shared.getCacheImage(for: movie.posterPath)
        }
    }
}
