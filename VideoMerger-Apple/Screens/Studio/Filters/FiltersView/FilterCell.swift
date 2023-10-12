//
//  FilterCell.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 03/10/2023.
//

import UIKit

final class FilterCell: UICollectionViewCell {
    
    private var stackView: UIStackView!
    private var imageView: UIImageView!
    private var titleLabel: Label!
    static let titleHeight: CGFloat = 50
    
    override var isSelected: Bool {
        willSet {
            if newValue {
                titleLabel.textColor = Constants.tintColor
                imageView.alpha = 1
            } else {
                titleLabel.textColor = Constants.foregroundColor
                imageView.alpha = 0.5
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Setup
    
    private func setupUI() {
        
        setupStackView()
        setupTitleLabel()
        setupImageView()
    }
    
    private func setupStackView() {
        
        stackView = UIStackView()
        stackView.axis = .vertical
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupTitleLabel() {
        
        titleLabel = Label()
        stackView.addArrangedSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(FilterCell.titleHeight)
        }
        
        titleLabel.textAlignment = .center
        titleLabel.font = Font.small.uifont
    }
    
    private func setupImageView() {
        
        imageView = UIImageView()
        stackView.addArrangedSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }
    
    
    // MARK: Configuration
    
    func configure(with viewCellModel: FiltersCollectionViewCellModeling, currentVideoUrl: URL,
                   filtersManager: FiltersManager, localFileManager: LocalFileManager) {
        
        titleLabel.text = viewCellModel.imageFilter.title.uppercased()
        
        filtersManager.applyThumbnail(with: currentVideoUrl, imageFilter: viewCellModel.imageFilter,
                                      filtersManager: filtersManager, localFileManager: localFileManager) { [weak self] image in
            
            DispatchQueue.main.async {
                
                self?.imageView?.image = image
            }
        }
    }
}
