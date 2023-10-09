//
//  ClipsViewController.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 02/10/2023.
//

import UIKit

final class ClipsViewController: CollectionViewController {
    
    weak var delegate: ClipsViewControllerDelegate!
    private weak var clipsManager: ClipsManager!
    private weak var filtersManager: FiltersManager!
    
    private var selectedIndex = 0 {
        didSet {
            collectionView?.reloadData()
            delegate?.didSelectVideo(newIndex: selectedIndex)
        }
    }
    
    
    // MARK: Life Cycle
    
    init(delegate: ClipsViewControllerDelegate, clipsManager: ClipsManager, filtersManager: FiltersManager) {
        super.init()
        self.delegate = delegate
        self.clipsManager = clipsManager
        self.filtersManager = filtersManager
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Setup
    
    override func setupCollectionView() {
        super.setupCollectionView()
        
        collectionView.register(ClipCell.self, forCellWithReuseIdentifier: "ClipCell")
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}


// MARK: UICollectionViewDataSource

extension ClipsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return clipsManager.inputVideoURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ClipCell", for: indexPath) as? ClipCell {
            cell.configure(with: clipsManager.inputVideoURLs[indexPath.row],
                           imageFilter: filtersManager.filters[7],
                           filtersManager: filtersManager)
            return cell
        }
        return UICollectionViewCell()
    }
}


// MARK: UICollectionViewDelegate

extension ClipsViewController {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.isSelected = true
        selectedIndex = indexPath.row
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.isSelected = indexPath.row == selectedIndex
    }
}


protocol ClipsViewControllerDelegate: AnyObject {
    
    func didSelectVideo(newIndex: Int)
}
