//
//  ProfileViewController.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/21/22.
//
import UIKit
import Combine

final class ProfileViewController: UICollectionViewController {
    static let sectionHeaderElementKind = "section-header-element-kind"
    
    private enum Section: String, CaseIterable {
        case profile = "Profile"
        case favorite = "Favorite Shows"
    }
    
    enum Row: Hashable {
        case profile(Profile)
        case favorite(Movie)
    }
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Row>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Row>
    
    private let viewModel: ProfileViewModelRepresentable
    private var subscription: AnyCancellable?
    
    private let registerProfileCell = UICollectionView.CellRegistration<UICollectionViewListCell, Profile> { cell, indexPath, profile in
        var configuration = cell.defaultContentConfiguration()
        configuration.text = profile.username
        
        Task {
            let imageStringURL = profile.avatar?.gravatar?.hash ?? profile.avatar?.tmdb?.avatarPath
            configuration.image = await ImageCacheStore.shared.getCacheImage(for: imageStringURL)
            
            configuration.imageProperties.cornerRadius = cell.contentView.frame.height / 2
            cell.contentConfiguration = configuration
        }
        
        cell.contentConfiguration = configuration
        cell.isSelected = false
    }
    
    private let registerFavoriteCell = UICollectionView.CellRegistration<MoviesViewCell, Movie> { cell, indexPath, movie in
        cell.configCell(movie)
    }
    
    init(viewModel: ProfileViewModelRepresentable) {
        self.viewModel = viewModel
        super.init(collectionViewLayout: Self.generateLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        configureCollectionView()
        bindUI()
    }
    
    private func setUI() {
        view.backgroundColor = .white
        viewModel.getAccountDetails()
        applySnapshot(favorites: [])
    }
    
    private func bindUI() {
        subscription = viewModel.favoritesSubject.sink { [unowned self] completion in
            switch completion {
            case .finished:
                print("Received completion in VC", completion)
            case .failure(let error):
                presentErrorAlert(for: error.errorCode.rawValue, with: (error.message))
            }
        } receiveValue: { [unowned self] favorites in
            applySnapshot(favorites: favorites)
        }
    }
    
    private func configureCollectionView() {
        collectionView.register(HeaderView.self,
                                forSupplementaryViewOfKind: Self.sectionHeaderElementKind,
                                withReuseIdentifier: HeaderView.reuseIdentifier)
        
        dataSource.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            
            guard let supplementaryView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: HeaderView.reuseIdentifier,
                for: indexPath) as? HeaderView else { fatalError("Cannot create header view") }
            
            let sectionName = Section.allCases[indexPath.section].rawValue
            supplementaryView.configCell(for: sectionName)
            return supplementaryView
        }
    }
    
    private lazy var dataSource: DataSource = { [unowned self] in
        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, row ->  UICollectionViewCell in
            switch row {
            case .profile(let profile):
                return collectionView.dequeueConfiguredReusableCell(using: self.registerProfileCell, for: indexPath, item: profile)
            case .favorite(let favorite):
                return collectionView.dequeueConfiguredReusableCell(using: self.registerFavoriteCell, for: indexPath, item: favorite)
            }
        }
        return dataSource
    }()
    
    private func applySnapshot(favorites: [Movie]) {
        var snapshot = Snapshot()
        
        guard let profileItem = viewModel.profileItem else { return }
        let profile = Row.profile(profileItem)
        let favorites = favorites.map { Row.favorite($0) }
        
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems([profile], toSection: .profile)
        snapshot.appendItems(favorites, toSection: .favorite)
        
        dataSource.apply(snapshot)
    }
}

extension ProfileViewController {
    
    static private func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let sectionLayoutKind = Section.allCases[sectionIndex]
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                            elementKind: Self.sectionHeaderElementKind,
                                                                            alignment: .top)
            
            switch sectionLayoutKind {
            case .profile:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .absolute(150))
                
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [sectionHeader]
                
                return section
            case .favorite:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalWidth(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .absolute(140),
                    heightDimension: .absolute(100))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 1)
                group.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
                
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [sectionHeader]
                section.orthogonalScrollingBehavior = .groupPaging
                
                return section
            }
        }
        return layout
    }
}


import UIKit

final class HeaderView: UICollectionReusableView {
    static let reuseIdentifierr = "header-reuse-identifier"
    
    private var label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .preferredFont(forTextStyle: .title3)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

extension HeaderView {
    func setUI() {
        backgroundColor = .systemBackground
        addSubview(label)
        
        let inset = CGFloat(10)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset),
            label.topAnchor.constraint(equalTo: topAnchor, constant: inset),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset)
        ])
    }
    
    func configCell(for text: String) {
        label.text = text
    }
}
