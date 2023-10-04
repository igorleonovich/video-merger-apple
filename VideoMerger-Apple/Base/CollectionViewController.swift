//
//  CollectionViewController.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 04/10/2023.
//

import UIKit

class CollectionViewController: BaseViewController {
    
    var collectionView: UICollectionView?
    let cellSize = CGSize(width: StudioViewController.fixedPanelsHeight, height: StudioViewController.fixedPanelsHeight)
    let cellGap: CGFloat = 1
}


// MARK: - Collection View Flow Layout Delegate

extension CollectionViewController: UICollectionViewDelegateFlowLayout {

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
