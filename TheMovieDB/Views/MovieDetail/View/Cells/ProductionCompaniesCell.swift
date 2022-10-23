//
//  ProductionCompaniesCell.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/23/22.
//

import UIKit

final class ProductionCompaniesCell: UICollectionViewCell {

    private var shadowView: UIView = {
        let outerView = UIView()
        outerView.shadow(opacity: 0.5)
        return outerView
    }()

    private var photoView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "MoviePlaceholder")
        imageView.layer.cornerRadius = 5
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private var nameLabel: UILabel = {
        let label = UILabel()
        label.configText(lines: 3, color: .white, sizeFont: 14, alignment: .center)
        label.shadow()
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configCell(_ movie: ProductionCompany) {
        nameLabel.text = movie.name
        Task {
            photoView.image = await ImageCacheStore.shared.getCacheImage(for: movie.logoPath)
        }
    }
    
    private func setUI() {
        addSubview(shadowView)
        shadowView.addSubview(photoView)
        addSubview(nameLabel)
        setupConstraint()
    }
    
    private func setupConstraint() {
        NSLayoutConstraint.activate([
            photoView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            photoView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            photoView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            photoView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),

            nameLabel.topAnchor.constraint(equalTo: photoView.bottomAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
        ])
    }
}
