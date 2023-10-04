//
//  StatusViewController.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 03/10/2023.
//

import UIKit

protocol StatusViewControllerDelegate: AnyObject {
    
    func didTapStatus()
}

final class StatusViewController: BaseViewController {
    
    private weak var delegate: StatusViewControllerDelegate!
    private var stackView: UIStackView!
    private var textLabel: Label!
    
    
    // MARK: Life Cycle
    
    init(delegate: StatusViewControllerDelegate) {
        self.delegate = delegate
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStackView()
        setupTextLabel()
        setupTapGesture()
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
        textLabel = Label()
        stackView.addArrangedSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        textLabel.textAlignment = .center
        textLabel.font = Font.large.uifont
        textLabel.textColor = .black
        
        textLabel.text = "Status".uppercased()
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    
    // MARK: Update
    
    func update(with text: String) {
        textLabel.text = text.uppercased()
    }
    
    // MARK: Actions
    
    @objc private func onTap(_ sender: Any) {
        delegate?.didTapStatus()
    }
}
