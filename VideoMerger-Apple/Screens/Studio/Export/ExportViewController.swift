//
//  ExportViewController.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 03/10/2023.
//


import AVKit
import ProgressHUD
import UIKit

final class ExportViewController: BaseViewController {
    
    private var url: URL
    
    private var stackView: UIStackView!
    
    // MARK: Life Cycle
    
    init(url: URL) {
        self.url = url
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        setupStackView()
        setupPlayer(with: url)
        setupSaveButton()
    }
    
    
    // MARK: Setup
    
    private func setupStackView() {
        
        stackView = UIStackView()
        stackView.axis = .vertical
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    private func setupPlayer(with url: URL) {
        
        let playerView = UIView()
        stackView.addArrangedSubview(playerView)
        
        let avPlayerViewController = AVPlayerViewController()
        let player = AVPlayer(url: url)
        avPlayerViewController.player = player
        self.addChild(avPlayerViewController)
        avPlayerViewController.view.frame = view.bounds
        
        avPlayerViewController.view.backgroundColor = view.backgroundColor
        
        add(child: avPlayerViewController, containerView: playerView)
        
        #if DEBUG
        player.volume = 0
        #endif
        player.play()
    }
    
    private func setupSaveButton() {
        
        let button = Button()
        button.snp.makeConstraints { make in
            make.height.equalTo(150)
        }
        stackView.addArrangedSubview(button)
        button.addTarget(self, action: #selector(onSave), for: .touchUpInside)
        
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Font.mediumBold.uifont
        button.setTitle("Save".uppercased(), for: .normal)
    }
    
    
    // MARK: Actions
    
    @objc private func onSave() {
        
        ProgressHUD.show()
        let objectsToShare = [url]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        present(activityVC, animated: true) {
            ProgressHUD.dismiss()
        }
    }
}
