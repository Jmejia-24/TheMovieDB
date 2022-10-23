//
//  InfoViewCell.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/23/22.
//

import UIKit

final class InfoViewCell: UICollectionViewCell {

    private var dateLabel = UILabel()
    private var ratingLabel = UILabel()
    private var popularityLabel = UILabel()
    private var genresLabel = UILabel()
    private var overviewLabel = UILabel()
    
    private lazy var labels = [dateLabel, ratingLabel, popularityLabel, genresLabel, overviewLabel]

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: labels)
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setUI() {
        backgroundColor = .clear
        addSubview(stackView)
        
        labels.forEach {
            $0.configText(lines: 0, color: .white, sizeFont: 18)
        }
        
        setupConstraint()
    }
    
    private func setupConstraint() {
        let inset = CGFloat(10)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: inset),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset)
        ])
    }
    
    func configCell(_ movie: Movie) {
        let genre = movie.genres?.compactMap({ $0.name}).joined(separator: ", ") ?? "Unspecified"
        
        dateLabel.text = "Release date: \(movie.releaseDate.printFormattedDate())"
        ratingLabel.text = "Rating: \(movie.voteAverage) \u{2B50}"
        popularityLabel.text = "Popularity: \(movie.popularity) \u{2764}"
        genresLabel.text = "Genres: \(genre)"
        overviewLabel.text = "Overview: \(movie.overview)"
    }
}
