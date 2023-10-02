//
//  ViewController.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 02/10/2023.
//

import AVFoundation
import SnapKit
import UIKit

final class StudioViewController: BaseViewController {

    private weak var core: Core!
    
    private var player: AVQueuePlayer!
    private var videoLooper: AVPlayerLooper!
    private var playerView: UIView!
    private var playerLayer: AVPlayerLayer!
    private var isPlayerSetup = false
    private var selectedVideoIndex = 0
    private var selectedFilter: ImageFilter = .inversion
    
    private var asset: AVAsset!
    private var inputVideoURLs = [URL]()
    private var outputVideoURLs = [URL]()
    
    private var filteringGroup: DispatchGroup!
    
    init(videoURLs: [URL], core: Core) {
        self.inputVideoURLs = videoURLs
        self.core = core
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPlayerView()
        
        /* INFO: Applying filter before merge for displaying it in preview and for avoiding filtering of added black space in case of different aspect ratio */
        Log.standard("\n[STUDIO] Filtering started...")
        
        filteringGroup = DispatchGroup()
        
        inputVideoURLs.forEach { videoURL in
            applyFilterAndExport(url: videoURL)
        }
        
        filteringGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            Log.standard("\n[STUDIO] Merging started...")
            mergeAndExport()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard isPlayerSetup == false else {
            return
        }
        // INFO: Prevent wrong player frame size
        if let url = inputVideoURLs.first {
            setupPlayer(with: url)
        } else {
            Log.error("\n[STUDIO] Can't load initial video into player")
        }
    }
    
    // MARK: - Setup
    
    private func setupPlayerView() {
        
        playerView = UIView()
        view.addSubview(playerView)
        playerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        view.layoutIfNeeded()
    }
    
    private func setupPlayer(with url: URL) {
        
        asset = AVAsset(url: url)
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
        
        isPlayerSetup = true
    }
    
    func removePlayer() {
         playerLayer?.removeFromSuperlayer()
     }
    
    // MARK: - Actions
    
    private func applyFilterAndExport(url: URL) {
        
        filteringGroup.enter()
        
        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        let videoComposition = AVMutableVideoComposition(asset: asset) { [weak self] request in
            guard let self = self else { return }
            let filter = self.selectedFilter.filter
            let source = request.sourceImage.clampedToExtent()
            filter.setValue(source, forKey: kCIInputImageKey)

            let output = filter.outputImage!.cropped(to: request.sourceImage.extent)
            // OPTIONAL TODO: Check different aspect ratio modes
            // let output = filter.outputImage!
            
            // INFO: Provide the filter output to the composition
            request.finish(with: output, context: nil)
        }
        item.videoComposition = videoComposition

        let exporter = AVAssetExportSession(asset: item.asset, presetName: AVAssetExportPresetHighestQuality)
        exporter?.videoComposition = videoComposition
        exporter?.outputFileType = .mp4
        
        let outputURL = core.localFileManager.fileURL(fileName: "\(url.fileName).\(self.selectedFilter.rawValue)", fileFormat: url.pathExtension)
        exporter?.outputURL = outputURL
        exporter?.exportAsynchronously(completionHandler: { [weak self] in
            guard let self = self, exporter?.status == .completed else {
                Log.error("\n[STUDIO] Export failed: \(exporter?.error)")
                return
            }
            outputVideoURLs.append(outputURL)
            
            Log.standard("\n[STUDIO] Export filtered video done:\n\(outputURL)")
            
            DispatchQueue.main.async { [weak self] in
                
                self?.removePlayer()
                // TODO: Pass item instead of url?
                self?.setupPlayer(with: outputURL)
                
//                self?.player.removeAllItems()
//                [item].forEach{
//                    self?.player.insert($0, after: nil)
//                }
//                self?.player.seek(to: .zero)
//                self?.player.play()
            }
            
            self.filteringGroup.leave()
        })
    }
    
    private func mergeAndExport() {
        
        let assets = outputVideoURLs.map({ AVAsset(url: $0) })
        core.videoManager.merge(arrayVideos: assets) { [weak self] mergedVideoURL, error in
            if let error = error {
                Log.error("\n[STUDIO] Merge failed:\n\(error)")
            } else if let mergedVideoURL = mergedVideoURL {
                Log.standard("\n[STUDIO] Merge done:\n\(mergedVideoURL)")
            } else {
                Log.error("\n[STUDIO] Merged video url creating failed")
            }
        }
    }
}
