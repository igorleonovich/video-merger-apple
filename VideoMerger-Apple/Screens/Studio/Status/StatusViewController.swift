//
//  StatusViewController.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 03/10/2023.
//

import UIKit

final class StatusViewController: BaseViewController {
    
    private var stackView: UIStackView!
    
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStackView()
        setupTextLabel()
    }
    
    
    // MARK: Setup
    
    private func setupStackView() {
        
        stackView = UIStackView()
        stackView.axis = .vertical
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupTextLabel() {
        let textLabel = Label()
        stackView.addArrangedSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        textLabel.textAlignment = .center
        textLabel.font = Font.large.uifont
        textLabel.textColor = .black
        
        textLabel.text = "Status".uppercased()
    }
    
    
    // MARK: Update
    
    func update() {
        
    }
}
