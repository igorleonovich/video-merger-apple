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
            make.height.equalTo(50)
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
    
    func configure(with url: URL, imageFilter: ImageFilter, filtersManager: FiltersManager, localFileManager: LocalFileManager) {
        
        titleLabel.text = imageFilter.title.uppercased()
        
        filtersManager.applyThumbnail(with: url, imageFilter: imageFilter,
                                      filtersManager: filtersManager, localFileManager: localFileManager) { [weak self] image in
            
            DispatchQueue.main.async {
                
                self?.imageView?.image = image
            }
        }
    }
}
