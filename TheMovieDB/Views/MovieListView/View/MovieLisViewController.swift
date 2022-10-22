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
    private var segmentedControlSubscription: AnyCancellable?
    
    private var viewModel: ListViewModelRepresentable
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
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
            
            let headerElement = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(390))
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
            
            headerElement.pinToVisibleBounds = true
            
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = [headerElement]
            return section
        }
        return layout
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bindUI()
        configureCollectionView()
    }
    
    // MARK: - Private methods
    
    private func configureCollectionView() {
        
        collectionView.register(header: SegmentedControlHeaderView.self)
        
        dataSource.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                               withReuseIdentifier: SegmentedControlHeaderView.reuseIdentifier,
                                                                               for: indexPath) as? SegmentedControlHeaderView
            else { fatalError("Cannot create header view") }
            
            self.segmentedControlSubscription = header.movieTypelSubject.sink { _ in
            } receiveValue: { [unowned self] listType in
                viewModel.currentListMovie = listType
            }
            return header
        }
    }
    
    private func setUI() {
        navigationItem.setHidesBackButton(true, animated: false)
        view.backgroundColor = .white
        title = "Movies"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "gear"),
            primaryAction: UIAction { [unowned self] _ in
                showSettingOptions()
            })
        
        collectionView.bounces = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.prefetchDataSource = self
        viewModel.fetchMovies(isPrefetch: false, offset: 1)
    }
    
    private func bindUI() {
        subscription = viewModel.movieListSubject.sink { [unowned self] completion in
            switch completion {
            case .finished:
                print("Received completion in VC", completion)
            case .failure(let error):
                presentErrorAlert(for: error.errorCode.rawValue, with: (error.message))
            }
        } receiveValue: { [unowned self] movies in
            collectionView.scrollsToTop = true
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
