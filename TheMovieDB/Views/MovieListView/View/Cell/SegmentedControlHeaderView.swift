//
//  SegmentedControlHeaderView.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/21/22.
//

import UIKit
import Combine

class SegmentedControlHeaderView: UICollectionReusableView {
    let movieTypelSubject = CurrentValueSubject<MovieType, Error>(.popular)

    private lazy var modeSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl()
        control.backgroundColor = .secondarySystemBackground
        control.translatesAutoresizingMaskIntoConstraints = false
        control.insertSegment(withTitle: "Popular", at: 0, animated: false)
        control.insertSegment(withTitle: "Upcoming", at: 1, animated: false)
        control.insertSegment(withTitle: "Now Playing", at: 2, animated: false)
        control.insertSegment(withTitle: "Top Rated", at: 3, animated: false)
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .red
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupView()
    }
    
    private func setupView() {
        addSubview(modeSegmentedControl)
        
        modeSegmentedControl.addAction( UIAction { [unowned self] _ in
            selctedControlValue()
        },for: .valueChanged)
        
        NSLayoutConstraint.activate([
            modeSegmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            modeSegmentedControl.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            bottomAnchor.constraint(equalTo: modeSegmentedControl.bottomAnchor, constant: 5),
            trailingAnchor.constraint(equalTo: modeSegmentedControl.trailingAnchor, constant: 15)
        ])
    }
    
    private func selctedControlValue() {
        switch modeSegmentedControl.selectedSegmentIndex {
        case 0:
            movieTypelSubject.send(.popular)
        case 1:
            movieTypelSubject.send(.upcoming)
        case 2:
            movieTypelSubject.send(.nowPlaying)
        case 3:
            movieTypelSubject.send(.topRated)
        default:
            break
        }
    }
}
