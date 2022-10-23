//
//  MovieViewCell.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/20/22.
//

import UIKit

final class MoviesViewCell: UICollectionViewCell {
    
    private var shadowView: UIView = {
        let outerView = UIView()
        outerView.shadow(opacity: 0.5)
        return outerView
    }()
    
    private var movieImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "MoviePlaceholder")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 15
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var movieTitle: UILabel = {
        let title = UILabel()
        title.configText()
        return title
    }()
    
    private var dateLabel: UILabel = {
        let date = UILabel()
        date.configText()
        return date
    }()
    
    private var ratingLabel: UILabel = {
        let rating = UILabel()
        rating.configText(alignment: .right)
        return rating
    }()
    
    private var descriptionLabel: UILabel = {
        let description = UILabel()
        description.configText(lines: 5, color: .white)
        return description
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [movieTitle, secondStackView, descriptionLabel])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var secondStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [dateLabel, ratingLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 5
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        movieImageView.image = UIImage(named: "MoviePlaceholder")
    }
    
    private func setUI() {
        backgroundColor = .backgroundList
        addSubview(shadowView)
        shadowView.addSubview(movieImageView)
        addSubview(stackView)
        shadow(cornerR: 20, opacity: 0.5)
    }
    
    private func setupConstraint() {
        NSLayoutConstraint.activate([
            movieImageView.heightAnchor.constraint(equalToConstant: 230),
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
        ratingLabel.text =  "★ \(movie.voteAverage)"
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
