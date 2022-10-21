//
//  MovieLisViewController.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/20/22.
//

import UIKit
import Combine

final class MovieLisViewController: UICollectionViewController {
    private enum Section: CaseIterable {
        case main
    }

    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Movie>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Movie>
    
    private var subscription: AnyCancellable?
    private let viewModel: ListViewModelRepresentable
    private var searchController = UISearchController(searchResultsController: nil)
    
    init(viewModel: ListViewModelRepresentable) {
        self.viewModel = viewModel
        super.init(collectionViewLayout: Self.generateLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static private func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(390))
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
            
            let section = NSCollectionLayoutSection(group: group)
            
            return section
        }
        return layout
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bindUI()
    }
    
    // MARK: - Private methods
    
    private func setUI() {
        view.backgroundColor = .white
        title = "TV Shows"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "gear"),
            primaryAction: UIAction { [unowned self] _ in
                showSettingOptions()
            })
        
        viewModel.fetchMovies(1)
        collectionView.prefetchDataSource = self
    }
    
    private func bindUI() {
        subscription = viewModel.movieListSubject.sink { [unowned self] completion in
            switch completion {
            case .finished:
                print("Received completion in VC", completion)
            case .failure(let error):
                presentAlert(with: error)
            }
        } receiveValue: { [unowned self] movies in
            applySnapshot(movies: movies)
        }
    }
    
    private func showSettingOptions() {
        UIAlertController.Builder()
            .withTitle("What do you want to do?")
            .withButton(style: .default, title: "View Profile") { [unowned self] _ in
                viewModel.goToProfile()
            }
            .withButton(style: .destructive, title: "Log out") { [unowned self] _ in
                viewModel.logOut()
            }
            .withButton(style: .cancel, title: "Cancel")
            .withAlertStyle(.actionSheet)
            .present(in: self)
    }
    
    private let registerMovieCell = UICollectionView.CellRegistration<MoviesViewCell, Movie> { cell, indexPath, movie in
        cell.configCell(movie)
    }
    
    private lazy var dataSource: DataSource = { [unowned self] in
        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item ->  UICollectionViewCell in
            
            return collectionView.dequeueConfiguredReusableCell(using: self.registerMovieCell, for: indexPath, item: item)
        }
        return dataSource
    }()

    private func applySnapshot(movies: [Movie]) {
        var snapshot = Snapshot()
        snapshot.appendSections(Section.allCases)
        Section.allCases.forEach { snapshot.appendItems(movies, toSection: $0) }
        dataSource.apply(snapshot)
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let movie = dataSource.itemIdentifier(for: indexPath) else { return }
        viewModel.didTapItem(model: movie)
    }
}

extension MovieLisViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        viewModel.prefetchData(for: indexPaths)
    }
}