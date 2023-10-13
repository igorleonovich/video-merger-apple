//
//  PreviewViewController.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 02/10/2023.
//

import AVFoundation
import UIKit

final class PreviewViewController: BaseViewController {
    
    var player: AVQueuePlayer!
    private var videoLooper: AVPlayerLooper!
    private var playerView: UIView!
    private var playerLayer: AVPlayerLayer!
    var isPlayerSetup = false
    
    
    // MARK: Setup
    
    func setupPlayerView() {
        
        playerView = UIView()
        view.addSubview(playerView)
        playerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        view.layoutIfNeeded()
    }
    
    func setupPlayer(with url: URL) {
        
        UIView.transition(with: view, duration: Constants.defaultAnimationDuration, options: .transitionCrossDissolve) { [weak self] in
            
            guard let self = self else { return }
            
            let asset = AVAsset(url: url)
            let item = AVPlayerItem(asset: asset)
            player = AVQueuePlayer(playerItem: item)
            
            #if DEBUG
            player.volume = 0
            #endif
            
            videoLooper = AVPlayerLooper(player: player, templateItem: item)
            
            playerLayer = AVPlayerLayer()
            playerLayer.player = player
            playerLayer.frame = playerView.bounds
            playerLayer.backgroundColor = UIColor.black.cgColor
            playerLayer.videoGravity = .resizeAspectFill
            playerView.layer.addSublayer(playerLayer)
            player.play()
        }
    }
}
