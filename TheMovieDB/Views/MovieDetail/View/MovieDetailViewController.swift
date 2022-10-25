//
//  MovieDetailViewController.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/21/22.
//

import UIKit
import Combine

final class MovieDetailViewController: UICollectionViewController {
    
    private enum Section: String, CaseIterable {
        case poster
        case info = "Info"
        case productionCompanie = "Production Companies"
    }
    
    enum Row: Hashable {
        case poster(Movie)
        case info(Movie)
        case productionCompanie(ProductionCompany)
    }
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Row>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Row>
    
    private var viewModel: MovieDetailViewModelRepresentable
    private var subscription: AnyCancellable?
    
    private let registerPosterCell = UICollectionView.CellRegistration<PosterHeaderCell, Movie> { cell, indexPath, movie in
        cell.configCell(movie)
    }
    
    private let registerInfoCell = UICollectionView.CellRegistration<InfoViewCell, Movie> { cell, indexPath, movie in
        cell.configCell(movie)
    }
    
    private let registerCompanieCell = UICollectionView.CellRegistration<ProductionCompaniesCell, ProductionCompany> { cell, indexPath, companie in
        cell.configCell(companie)
    }
    
    init(viewModel: MovieDetailViewModelRepresentable) {
        self.viewModel = viewModel
        super.init(collectionViewLayout: Self.generateLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bindUI()
    }
    
    lazy var favoriteButtonItem: UIBarButtonItem = {
        return UIBarButtonItem (
            image: UIImage(systemName: viewModel.movie.isFavorite ? "heart.fill" : "heart"),
            primaryAction: UIAction { [unowned self] re in
                viewModel.movie.isFavorite = true
                favoriteButtonItem.isEnabled = !viewModel.movie.isFavorite
                favoriteButtonItem.image = UIImage(systemName: "heart.fill")
                viewModel.saveToFavorite()
            })
    }()
    
    private func setUI() {
        title = "Details"
        collectionView.showsVerticalScrollIndicator = false
        collectionView.bounces = false
        navigationItem.rightBarButtonItem = favoriteButtonItem
        favoriteButtonItem.isEnabled = !viewModel.movie.isFavorite
        configureCollectionView()
        viewModel.fetchMovieDetail()
    }
    
    private func bindUI() {
        subscription = viewModel.movieDetailSubject.sink { [unowned self] completion in
            switch completion {
            case .finished:
                print("Received completion in VC", completion)
            case .failure(let error):
                presentErrorAlert(for: error.errorCode.rawValue, with: (error.message))
            }
        } receiveValue: { [unowned self] movie in
            guard let movie = movie else { return }
            applySnapshot(movie: movie)
        }
    }
    
    private func configureCollectionView() {
        collectionView.register(HeaderView.self,
                                forSupplementaryViewOfKind: HeaderView.reuseIdentifier,
                                withReuseIdentifier: HeaderView.reuseIdentifier)
        
        dataSource.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            
            guard let supplementaryView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: HeaderView.reuseIdentifier,
                for: indexPath) as? HeaderView else { fatalError("Cannot create header view") }
            
            let sectionName = Section.allCases[indexPath.section].rawValue
            supplementaryView.config(for: sectionName)
            return supplementaryView
        }
    }
    
    private lazy var dataSource: DataSource = { [unowned self] in
        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, row ->  UICollectionViewCell in
            switch row {
            case .poster(let poster):
                return collectionView.dequeueConfiguredReusableCell(using: self.registerPosterCell, for: indexPath, item: poster)
            case .info(let info):
                return collectionView.dequeueConfiguredReusableCell(using: self.registerInfoCell, for: indexPath, item: info)
            case .productionCompanie(let companie):
                return collectionView.dequeueConfiguredReusableCell(using: self.registerCompanieCell, for: indexPath, item: companie)
            }
        }
        return dataSource
    }()
    
    private func applySnapshot(movie: Movie) {
        var snapshot = Snapshot()
        
        let companies = movie.productionCompanies?.compactMap { Row.productionCompanie($0) } ?? []
        
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems([.poster(movie)], toSection: .poster)
        snapshot.appendItems([.info(movie)], toSection: .info)
        snapshot.appendItems(companies, toSection: .productionCompanie)
        
        dataSource.apply(snapshot)
    }
}

extension MovieDetailViewController {
    static private func generateLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { index, _  in
            let section = Section.allCases[index]
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                            elementKind: HeaderView.reuseIdentifier,
                                                                            alignment: .top)
            
            switch section {
            case .poster, .info:
                let headerItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                                                           heightDimension: .fractionalHeight(1.0)))
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .fractionalHeight(0.4))
                
                let headerGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [headerItem])
                headerGroup.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0)
                
                
                return NSCollectionLayoutSection(group: headerGroup)
            case .productionCompanie:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalWidth(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .absolute(250),
                    heightDimension: .absolute(200))
                
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 1)
                group.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
                
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [sectionHeader]
                section.orthogonalScrollingBehavior = .groupPaging
                
                return section
            }
            
        }
    }
}
