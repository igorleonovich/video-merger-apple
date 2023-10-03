//
//  ClipsViewController.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 02/10/2023.
//

import UIKit

final class ClipsViewController: BaseViewController {
    
    weak var delegate: ClipsViewControllerDelegate?
    weak private var clipsManager: ClipsManager!
    
    private var collectionView: UICollectionView?
    private let cellSize = CGSize(width: StudioViewController.fixedPanelsHeight, height: StudioViewController.fixedPanelsHeight)
    private let cellGap: CGFloat = 1
    
    private var selectedIndex = 0 {
        didSet {
            collectionView?.reloadData()
            delegate?.didSelectVideo(newIndex: selectedIndex)
        }
    }
    
    
    // MARK: Life Cycle
    
    init(delegate: ClipsViewControllerDelegate? = nil, clipsManager: ClipsManager) {
        super.init()
        self.delegate = delegate
        self.clipsManager = clipsManager
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    
    // MARK: Setup
    
    private func setupCollectionView() {
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout())
        self.collectionView = collectionView
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        collectionView.register(ClipCell.self, forCellWithReuseIdentifier: "ClipCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.decelerationRate = .fast
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = .zero
        
        func collectionViewLayout() -> UICollectionViewLayout {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            return layout
        }
    }
}


// MARK: - Collection View Data Source

extension ClipsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return clipsManager.inputVideoURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ClipCell", for: indexPath) as? ClipCell {
            cell.configure(with: clipsManager.inputVideoURLs[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }
}


// MARK: - Collection View Flow Layout Delegate

extension ClipsViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellGap
    }
}


extension ClipsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.isSelected = indexPath.row == selectedIndex
    }
}


protocol ClipsViewControllerDelegate: AnyObject {
    
    func didSelectVideo(newIndex: Int)
}

