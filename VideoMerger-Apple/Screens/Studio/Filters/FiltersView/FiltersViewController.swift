//
//  FiltersViewController.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 02/10/2023.
//

import RxSwift
import UIKit

final class FiltersViewController: CollectionViewController {
    
    weak var delegate: FiltersViewControllerDelegate!
    weak var filtersManager: FiltersManager!
    weak var localFileManager: LocalFileManager!
    
    static var height: CGFloat {
        return CollectionViewController.cellSide + FilterCell.titleHeight
    }
    override var cellSize: CGSize {
        return CGSize(width: CollectionViewController.cellSide, height: FiltersViewController.height)
    }
    
    private var selectedIndex = 0 {
        didSet {
            collectionView?.reloadData()
            delegate?.didSelectFilter(newIndex: selectedIndex)
        }
    }
    
    var currentVideoUrl: URL!
    
    public var viewModel: FiltersCollectionViewModeling?
    private var viewCellModels: [FiltersCollectionViewCellModeling] = []
    private var disposeBag = DisposeBag()
    
    
    // MARK: Life Cycle
    
    override init() {
        super.init()
    }
    
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
        
        viewModel?.getFilters().subscribe(onNext: { viewCellModels in
            DispatchQueue.main.async { [weak self] in
                
                guard let network = self?.viewModel?.network else { return }
                
                let noFilterCellModel = FiltersCollectionViewCellModel(network: network)
                var allViewCellModels = viewCellModels
                allViewCellModels.insert(noFilterCellModel, at: 0)
                self?.viewCellModels = allViewCellModels
                
                self?.collectionView.reloadData()
                
                // INFO: Pass filters to FiltersManager for Clips and maybe other modules in future
                self?.filtersManager.filters.append(contentsOf: allViewCellModels.map({ $0.imageFilter }))
            }
        })
        .disposed(by: disposeBag)
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
        
        return viewCellModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath) as? FilterCell {
            cell.configure(with: currentVideoUrl, viewCellModel: viewCellModels[indexPath.row], filtersManager: filtersManager, localFileManager: localFileManager)
            return cell
        }
        return UICollectionViewCell()
    }
}


// MARK: UICollectionViewDelegate

extension FiltersViewController {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.isSelected = indexPath.row == selectedIndex
    }
}


protocol FiltersViewControllerDelegate: AnyObject {
    
    func didSelectFilter(newIndex: Int)
}
