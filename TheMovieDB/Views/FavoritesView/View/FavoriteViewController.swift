//
//  FavoriteViewController.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/22/22.
//

import UIKit
import Combine

final class FavoriteViewController: UICollectionViewController {
    private enum Section: CaseIterable {
        case main
    }
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, MovieObject>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, MovieObject>
    
    private var subscription: AnyCancellable?
    private var viewModel: FavoriteViewModelRepresentable
    
    init(viewModel: FavoriteViewModelRepresentable) {
        self.viewModel = viewModel
        super.init(collectionViewLayout: Self.generateLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static private func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(390))
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
            
            return NSCollectionLayoutSection(group: group)
        }
        return layout
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bindUI()
    }
    
    private func setUI() {
        title = "Favorites"
        
        collectionView.bounces = false
        collectionView.showsVerticalScrollIndicator = false
        viewModel.loadFavoriteMovies(0)
    }
    
    private func bindUI() {
        subscription = viewModel.favoritesSubject.sink { [unowned self] completion in
            switch completion {
            case .finished:
                print("Received completion in VC", completion)
            case .failure(let error):
                presentErrorAlert(with: error.localizedDescription)
            }
        } receiveValue: { [unowned self] movies in
            applySnapshot(movies: movies)
        }
    }
    
    private let registerMovieCell = UICollectionView.CellRegistration<MoviesViewCell, MovieObject> { cell, indexPath, movie in
        cell.configCell(movieObject: movie)
    }
    
    private lazy var dataSource: DataSource = { [unowned self] in
        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item ->  UICollectionViewCell in
            collectionView.dequeueConfiguredReusableCell(using: self.registerMovieCell, for: indexPath, item: item)
        }
        return dataSource
    }()
    
    private func applySnapshot(movies: [MovieObject]) {
        var snapshot = Snapshot()
        snapshot.appendSections(Section.allCases)
        Section.allCases.forEach { snapshot.appendItems(movies, toSection: $0) }
        dataSource.apply(snapshot)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let movie = dataSource.itemIdentifier(for: indexPath) else { return }
        didTapItem(movie)
    }
    
    private func didTapItem(_ movie: MovieObject) {
        UIAlertController.Builder()
            .withTitle(movie.movie?.title)
            .withMessage("Do you want to remove this movie?")
            .withButton(style: .destructive, title: "Delete") { [unowned self] _ in
                var snapshot = dataSource.snapshot()
                snapshot.deleteItems([movie])
                dataSource.apply(snapshot)
                
                viewModel.deleteMovie(movie: movie)
            }
            .withButton(style: .cancel, title: "Cancel")
            .withAlertStyle(.actionSheet)
            .present(in: self)
    }
}
