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
    weak var clipsManager: ClipsManager!
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
    
    public var viewModel: FiltersCollectionViewModeling?
    private lazy var viewCellModels: [FiltersCollectionViewCellModeling] = {
        guard let viewModel = viewModel else { return [] }
        let noFilterCellModel = FiltersCollectionViewCellModel(network: viewModel.network)
        return [noFilterCellModel]
    }()
    private var disposeBag = DisposeBag()
    
    
    // MARK: Life Cycle
    
    override init() {
        super.init()
    }
    
    init(delegate: FiltersViewControllerDelegate,
         filtersManager: FiltersManager, clipsManager: ClipsManager, localFileManager: LocalFileManager) {
        super.init()
        self.delegate = delegate
        self.filtersManager = filtersManager
        self.clipsManager = clipsManager
        self.localFileManager = localFileManager
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel?.getFilters().subscribe(onNext: { viewCellModels in
            DispatchQueue.main.async { [weak self] in
                
                guard let self = self else { return }
                
                self.viewCellModels.append(contentsOf: viewCellModels)
                
                filtersManager.filters.append(contentsOf: viewCellModels.map({ $0.imageFilter }))
                
                filtersManager.generateThumbnailsForCurrentVideoAndAllFilters {
                    UIView.transition(with: self.view, duration: Constants.defaultAnimationDuration,
                                      options: .transitionCrossDissolve, animations: { [weak self] in
                        self?.collectionView.reloadData()
                    })
                }
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
        
        /* TODO: Ideally it should be just reading url of pre-processed image by separate manager.
           Thus cells could be loaded independently from the processing. */
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath) as? FilterCell {
            cell.configure(with: viewCellModels[indexPath.row],
                           currentVideoUrl: clipsManager.inputVideoURLs[clipsManager.selectedClipIndex], localFileManager: localFileManager)
            return cell
        }
        return UICollectionViewCell()
    }
}


// MARK: UICollectionViewDelegate

extension FiltersViewController {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.isSelected = indexPath.row == selectedIndex
    }
}


protocol FiltersViewControllerDelegate: AnyObject {
    
    func didSelectFilter(newIndex: Int)
}
