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
        imageView.layer.cornerRadius = 12
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
        date.font = .preferredFont(forTextStyle: .headline)
        date.translatesAutoresizingMaskIntoConstraints = false
        return date
    }()

    private var ratingLabel: UILabel = {
        let rating = UILabel()
        rating.numberOfLines = 1
        rating.font = .preferredFont(forTextStyle: .subheadline)
        rating.translatesAutoresizingMaskIntoConstraints = false
        rating.textAlignment = .right
        return rating
    }()

    private var descriptionLabel: UILabel = {
        let description = UILabel()
        description.numberOfLines = 4
        description.textAlignment = .left
        description.font = UIFont.boldSystemFont(ofSize: 15)
        description.translatesAutoresizingMaskIntoConstraints = false
        return description
    }()

    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [movieImageView, firstStackView])
        stackView.backgroundColor = .systemGray
        stackView.axis = .vertical
        stackView.layer.cornerRadius = 12
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var firstStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [movieTitle, secondStackView, descriptionLabel])
        stackView.axis = .vertical
        stackView.layer.cornerRadius = 12
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 2
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
        addSubview(mainStackView)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupView() {
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),

            movieImageView.widthAnchor.constraint(equalTo: mainStackView.widthAnchor),
            movieImageView.heightAnchor.constraint(equalToConstant: 200),
            
            
            firstStackView.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor, constant: 10),
            firstStackView.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor, constant: -10),
        ])
    }

    func configCell(_ movie: Movie) {
        movieTitle.text = movie.title
        dateLabel.text = movie.releaseDate
        ratingLabel.text =  "\u{2B50}" + "\(movie.voteAverage) "
        descriptionLabel.text = movie.overview
        
        Task {
            movieImageView.image = await ImageCacheStore.shared.getCacheImage(for: movie.posterPath)
        }
    }
}


