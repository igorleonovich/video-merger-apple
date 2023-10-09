//
//  FiltersViewController.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 02/10/2023.
//

import UIKit

final class FiltersViewController: CollectionViewController {
    
    weak var delegate: FiltersViewControllerDelegate!
    private weak var filtersManager: FiltersManager!
    private weak var localFileManager: LocalFileManager!
    
    override var cellSize: CGSize {
        return CGSize(width: CollectionViewController.cellSide, height: 150)
    }
    
    private var selectedIndex = 0 {
        didSet {
            collectionView?.reloadData()
            delegate?.didSelectFilter(newIndex: selectedIndex)
        }
    }
    
    var currentVideoUrl: URL!
    
    
    // MARK: Life Cycle
    
    init(delegate: FiltersViewControllerDelegate, filtersManager: FiltersManager, localFileManager: LocalFileManager) {
        super.init()
        self.delegate = delegate
        self.filtersManager = filtersManager
        self.localFileManager = localFileManager
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filtersManager.load { [weak self] in
            self?.collectionView?.reloadData()
        }
    }
    
    
    // MARK: Setup
    
    override func setupCollectionView() {
        super.setupCollectionView()
        
        collectionView.register(FilterCell.self, forCellWithReuseIdentifier: "FilterCell")
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}


// MARK: UICollectionViewDataSource

extension FiltersViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return filtersManager.filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath) as? FilterCell {
            cell.configure(with: currentVideoUrl, imageFilter: filtersManager.filters[indexPath.row], filtersManager: filtersManager, localFileManager: localFileManager)
            return cell
        }
        return UICollectionViewCell()
    }
}


// MARK: UICollectionViewDelegate

extension FiltersViewController {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        collectionView.cellForItem(at: indexPath)?.isSelected = true
        selectedIndex = indexPath.row
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.isSelected = indexPath.row == selectedIndex
    }
}


protocol FiltersViewControllerDelegate: AnyObject {
    
    func didSelectFilter(newIndex: Int)
}
