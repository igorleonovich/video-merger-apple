//
//  KVVideoManager.swift
//  MergeVideos
//
//  Created by Khoa Vo on 12/20/17.
//  Copyright © 2017 Khoa Vo. All rights reserved.
//

//
//  MergeManager.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 02/10/2023.
//

import AVFoundation
import UIKit

final class MergeManager {
    
    private weak var localFileManager: LocalFileManager!
    
    var mergedURL: URL?
    
    typealias Completion = (URL?, Error?) -> Void
    
    
    // MARK: - Life Cycle
    
    init(localFileManager: LocalFileManager) {
        self.localFileManager = localFileManager
    }
    
    
    // MARK: - Actions
    
    func merge(videoAssets: [AVAsset], completion: @escaping Completion) -> Void {
        
        var insertTime = CMTime.zero
        var arrayLayerInstructions = [AVMutableVideoCompositionLayerInstruction]()

        // Silence sound (in case video has no sound track)
        guard let silenceURL = Bundle.main.url(forResource: "silence", withExtension: "mp3") else {
            Log.error("[MERGE] Missing silence audio resource")
            completion(nil, nil)
            return
        }
        
        let silenceAsset = AVAsset(url: silenceURL)
        let silenceSoundTrack = silenceAsset.tracks(withMediaType: AVMediaType.audio).first
        
        // Init composition
        let mixComposition = AVMutableComposition()
        
        for videoAsset in videoAssets {
            // Get video track
            guard let videoTrack = videoAsset.tracks(withMediaType: AVMediaType.video).first else { continue }
            
            // Get audio track
            var audioTrack: AVAssetTrack?
            if videoAsset.tracks(withMediaType: AVMediaType.audio).count > 0 {
                audioTrack = videoAsset.tracks(withMediaType: AVMediaType.audio).first
            }
            else {
                audioTrack = silenceSoundTrack
            }
            
            // Init video & audio composition track
            let videoCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video,
                                                                       preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
            
            let audioCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio,
                                                                       preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
            
            do {
                let startTime = CMTime.zero
                let duration = videoAsset.duration
                
                // Add video track to video composition at specific time
                try videoCompositionTrack?.insertTimeRange(CMTimeRangeMake(start: startTime, duration: duration),
                                                           of: videoTrack,
                                                           at: insertTime)
                
                // Add audio track to audio composition at specific time
                if let audioTrack = audioTrack {
                    try audioCompositionTrack?.insertTimeRange(CMTimeRangeMake(start: startTime, duration: duration),
                                                               of: audioTrack,
                                                               at: insertTime)
                }
                
                // Add instruction for video track
                if let videoCompositionTrack = videoCompositionTrack {
                    let layerInstruction = videoCompositionInstructionForTrack(track: videoCompositionTrack,
                                                                               asset: videoAsset,
                                                                               targetSize: Constants.defaultVideoSize)
                    
                    // Hide video track before changing to new track
                    let endTime = CMTimeAdd(insertTime, duration)
                    
                    layerInstruction.setOpacity(0, at: endTime)
                    
                    arrayLayerInstructions.append(layerInstruction)
                }
                
                // Increase the insert time
                insertTime = CMTimeAdd(insertTime, duration)
            }
            catch {
                Log.error("[MERGE] Load track error:\n\(videoAsset)")
            }
        }
        
        // Main video composition instruction
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: insertTime)
        mainInstruction.layerInstructions = arrayLayerInstructions
        
        // Main video composition
        let mainComposition = AVMutableVideoComposition()
        mainComposition.instructions = [mainInstruction]
        mainComposition.frameDuration = CMTimeMake(value: 1, timescale: Constants.frameDuration)
        mainComposition.renderSize = Constants.defaultVideoSize
        
        // Export to file
        let exportURL = localFileManager.fileURL(fileName: "merged", fileFormat: Constants.outputExtension)
        
        // Remove file if exists
        localFileManager.removeFileIfExists(exportURL)
        
        // Init exporter
        let exporter = AVAssetExportSession.init(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)
        exporter?.outputURL = exportURL
        exporter?.outputFileType = AVFileType(rawValue: Constants.outputFileType)
        // TODO: Pass as a parameter?
        exporter?.shouldOptimizeForNetworkUse = true
        exporter?.videoComposition = mainComposition
        
        // Do export
        exporter?.exportAsynchronously(completionHandler: {
            DispatchQueue.main.async {
                self.exportDidFinish(exporter: exporter, videoURL: exportURL, completion: completion)
            }
        })
    }
}


// MARK: Helpers

extension MergeManager {
    
    private func videoCompositionInstructionForTrack(track: AVCompositionTrack?,
                                                     asset: AVAsset,
                                                     targetSize: CGSize) -> AVMutableVideoCompositionLayerInstruction {
        
        guard let track = track else { return AVMutableVideoCompositionLayerInstruction() }
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        let assetTrack = asset.tracks(withMediaType: AVMediaType.video)[0]

        let transform = assetTrack.fixedPreferredTransform
        let assetInfo = orientationFromTransform(transform)
        
        var scaleToFitRatio = targetSize.width / assetTrack.naturalSize.width
        if assetInfo.isPortrait {
            // Scale to fit target size
            scaleToFitRatio = targetSize.width / assetTrack.naturalSize.height
            let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
            
            // Align center Y
            let newY = targetSize.height / 2 - (assetTrack.naturalSize.width * scaleToFitRatio) / 2
            let moveCenterFactor = CGAffineTransform(translationX: 0, y: newY)
            
            let finalTransform = transform.concatenating(scaleFactor).concatenating(moveCenterFactor)

            instruction.setTransform(finalTransform, at: .zero)
        } else {
            // Scale to fit target size
            let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
            
            // Align center Y
            let newY = targetSize.height / 2 - (assetTrack.naturalSize.height * scaleToFitRatio) / 2
            let moveCenterFactor = CGAffineTransform(translationX: 0, y: newY)
            
            let finalTransform = transform.concatenating(scaleFactor).concatenating(moveCenterFactor)
            
            instruction.setTransform(finalTransform, at: .zero)
        }

        return instruction
    }
    
    private func orientationFromTransform(_ transform: CGAffineTransform) -> (orientation: UIImage.Orientation, isPortrait: Bool) {
        
        var assetOrientation = UIImage.Orientation.up
        var isPortrait = false
        
        switch [transform.a, transform.b, transform.c, transform.d] {
        case [0.0, 1.0, -1.0, 0.0]:
            assetOrientation = .right
            isPortrait = true
            
        case [0.0, -1.0, 1.0, 0.0]:
            assetOrientation = .left
            isPortrait = true
            
        case [1.0, 0.0, 0.0, 1.0]:
            assetOrientation = .up
            
        case [-1.0, 0.0, 0.0, -1.0]:
            assetOrientation = .down

        default:
            break
        }
    
        return (assetOrientation, isPortrait)
    }
    
    private func setOrientation(image: UIImage?, onLayer: CALayer, outputSize:CGSize) -> Void {
        
        guard let image = image else { return }

        if image.imageOrientation == UIImage.Orientation.up {
            // Do nothing
        }
        else if image.imageOrientation == UIImage.Orientation.left {
            let rotate = CGAffineTransform(rotationAngle: .pi / 2)
            onLayer.setAffineTransform(rotate)
        }
        else if image.imageOrientation == UIImage.Orientation.down {
            let rotate = CGAffineTransform(rotationAngle: .pi)
            onLayer.setAffineTransform(rotate)
        }
        else if image.imageOrientation == UIImage.Orientation.right {
            let rotate = CGAffineTransform(rotationAngle: -.pi / 2)
            onLayer.setAffineTransform(rotate)
        }
    }
    
    private func exportDidFinish(exporter: AVAssetExportSession?, videoURL: URL, completion: @escaping Completion) -> Void {
        
        if exporter?.status == AVAssetExportSession.Status.completed {
            mergedURL = videoURL
            completion(videoURL, nil)
        }
        else if exporter?.status == AVAssetExportSession.Status.failed {
            completion(videoURL, exporter?.error)
        } else {
            completion(nil, exporter?.error)
        }
    }
}
