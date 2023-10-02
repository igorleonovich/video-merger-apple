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

class ViewController: UIViewController {

    private var player: AVQueuePlayer!
    private var videoLooper: AVPlayerLooper!
    private var playerView: UIView!
    private var playerLayer: AVPlayerLayer!
    private var asset: AVAsset!
    private var inputURL: URL? {
        return Bundle.main.url(forResource: "c-17", withExtension: "mp4")
    }
    private var outputURL: URL? {
        let filename = "export.mp4"
        let documentsDirectory = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).last!
        return documentsDirectory.appendingPathComponent(filename)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayerView()
        setupPlayer()
        applyFilterAndExport()
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
        guard let inputURL = inputURL else { return }
        asset = AVAsset(url: inputURL)
        let item = AVPlayerItem(asset: asset)
        player = AVQueuePlayer(playerItem: item)
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
        
        removeExistedFile()

        let exporter = AVAssetExportSession(asset: item.asset, presetName: AVAssetExportPresetHighestQuality)
        exporter?.videoComposition = videoComposition
        exporter?.outputFileType = .mp4
        
        guard let outputURL = outputURL else { return }
        exporter?.outputURL = outputURL
        exporter?.exportAsynchronously(completionHandler: {
            guard exporter?.status == .completed else {
                print("export failed: \(exporter?.error)")
                return
            }
            print("done: ", outputURL)
        })
    }
    
    private func removeExistedFile() {
        // TODO: Keep exported files list instead of re-writing existed
        guard let outputURL = outputURL else { return }
        do {
            try FileManager.default.removeItem(at: outputURL)
            print("Existed file removed")
        } catch {
            print(error.localizedDescription)
        }
    }
}

