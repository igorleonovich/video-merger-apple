//
//  FiltersViewController.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 02/10/2023.
//

import UIKit

final class FiltersViewController: CollectionViewController {
    
    weak var delegate: FiltersViewControllerDelegate?
    weak private var filtersManager: FiltersManager!
    
    private var selectedIndex = 0 {
        didSet {
            collectionView?.reloadData()
            delegate?.didSelectFilter(newIndex: selectedIndex)
        }
    }
    
    
    // MARK: Life Cycle
    
    init(delegate: FiltersViewControllerDelegate? = nil, filtersManager: FiltersManager) {
        super.init()
        self.delegate = delegate
        self.filtersManager = filtersManager
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
            cell.configure(with: filtersManager.filters[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }
}


// MARK: UICollectionViewDelegate

extension FiltersViewController {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.isSelected = true
        selectedIndex = indexPath.row
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.isSelected = indexPath.row == selectedIndex
    }
}


protocol FiltersViewControllerDelegate: AnyObject {
    
    func didSelectFilter(newIndex: Int)
}
