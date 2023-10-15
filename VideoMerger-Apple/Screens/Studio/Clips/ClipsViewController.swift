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
    private weak var localFileManager: LocalFileManager!
    
    private var selectedIndex = 0 {
        didSet {
            delegate?.didSelectClip(newIndex: selectedIndex)
            collectionView?.reloadData()
        }
    }
    
    
    // MARK: Life Cycle
    
    init(delegate: ClipsViewControllerDelegate, clipsManager: ClipsManager, filtersManager: FiltersManager,
         localFileManager: LocalFileManager) {
        super.init()
        self.delegate = delegate
        self.clipsManager = clipsManager
        self.filtersManager = filtersManager
        self.localFileManager = localFileManager
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
        
        filtersManager.generateThumbnailsForCurrentFilterAndAllVideos {
            self.collectionView.reloadData()
        }
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
                           imageFilter: filtersManager.filters[filtersManager.selectedFilterIndex], localFileManager: localFileManager)
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
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.defaultAnimationDuration * 0.2) {
            UIView.animate(withDuration: Constants.defaultAnimationDuration) {
                collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.isSelected = indexPath.row == selectedIndex
    }
}


protocol ClipsViewControllerDelegate: AnyObject {
    
    func didSelectClip(newIndex: Int)
}
