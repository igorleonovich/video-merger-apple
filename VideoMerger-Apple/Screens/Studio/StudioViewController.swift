//
//  ViewController.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 02/10/2023.
//

import AVFoundation
import CoreImage
import SnapKit
import UIKit

final class StudioViewController: BaseViewController {

    private weak var core: Core!
    
    private var player: AVQueuePlayer!
    private var videoLooper: AVPlayerLooper!
    private var playerView: UIView!
    private var playerLayer: AVPlayerLayer!
    private var asset: AVAsset!
    private var videoURLs = [URL]()
    
    init(videoURLs: [URL], core: Core) {
        self.videoURLs = videoURLs
        self.core = core
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayerView()
        applyFilterAndExport()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Prevent wrong player frame size
        setupPlayer()
    }
    
    private func setupPlayerView() {
        playerView = UIView()
        view.addSubview(playerView)
        playerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        view.layoutIfNeeded()
    }
    
    private func setupPlayer() {
        guard let inputURL = videoURLs.first else { return }
        asset = AVAsset(url: inputURL)
        let item = AVPlayerItem(asset: asset)
        player = AVQueuePlayer(playerItem: item)
        // TODO: Remove hardcode
//        player.isMuted = true
        player.volume = 0
        videoLooper = AVPlayerLooper(player: player, templateItem: item)
        
        playerLayer = AVPlayerLayer()
        playerLayer.player = player
        playerLayer.frame = playerView.bounds
        playerLayer.backgroundColor = UIColor.black.cgColor
        playerLayer.videoGravity = .resizeAspectFill
        playerView.layer.addSublayer(playerLayer)
        player.play()
    }
    
    private func applyFilterAndExport() {
        let item = AVPlayerItem(asset: asset)
        let videoComposition = AVMutableVideoComposition(asset: asset) { request in
            let filter = CIFilter(name: "CIColorInvert")!
            let source = request.sourceImage.clampedToExtent()
            filter.setValue(source, forKey: kCIInputImageKey)

            let output = filter.outputImage!.cropped(to: request.sourceImage.extent)
            
            // Provide the filter output to the composition
            request.finish(with: output, context: nil)
        }
        item.videoComposition = videoComposition
        player.replaceCurrentItem(with: item)
        player.play()

        let exporter = AVAssetExportSession(asset: item.asset, presetName: AVAssetExportPresetHighestQuality)
        exporter?.videoComposition = videoComposition
        exporter?.outputFileType = .mp4
        
        guard let outputURL = core.videoManager.outputURL else { return }
        exporter?.outputURL = outputURL
        exporter?.exportAsynchronously(completionHandler: {
            guard exporter?.status == .completed else {
                print("\n[STUDIO] Export failed: \(exporter?.error)")
                return
            }
            print("\n[STUDIO] Export done:", outputURL)
        })
    }
}
