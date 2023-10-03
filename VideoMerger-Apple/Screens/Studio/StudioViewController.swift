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

    private weak var localFileManager: LocalFileManager!
    private var mergeManager: MergeManager!
    private var filtersManager: FiltersManager!
    private var clipsManager: ClipsManager!
    
    private var stackView: UIStackView!
    private var previewView: UIView!
    static let fixedPanelsHeight: CGFloat = 100
    private let statusPanelHeight: CGFloat = 50
    
    private var player: AVQueuePlayer!
    private var videoLooper: AVPlayerLooper!
    private var playerView: UIView!
    private var playerLayer: AVPlayerLayer!
    private var isPlayerSetup = false
    
    private var selectedVideoIndex = 0 {
        didSet {
            print(selectedVideoIndex)
        }
    }
    private var selectedFilterIndex = 0 {
        didSet {
            print(selectedFilterIndex)
        }
    }
    
    private var filteringGroup: DispatchGroup!
    
    init(videoURLs: [URL], localFileManager: LocalFileManager) {
        clipsManager = ClipsManager()
        clipsManager.inputVideoURLs = videoURLs
        self.localFileManager = localFileManager
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mergeManager = MergeManager(localFileManager: localFileManager)
        filtersManager = FiltersManager()
        
        setupExport()
        
        setupStackView()
        
        setupClips()
        setupPreview()
        setupFilters()
        setupStatus()
        
        setupPlayerView()

        /* INFO: Applying filter before merge for displaying it in preview and for avoiding filtering of added black space in case of different aspect ratio */
        Log.standard("[STUDIO] Filtering started...")

        filteringGroup = DispatchGroup()

        clipsManager.inputVideoURLs.forEach { videoURL in
            applyFilterAndExport(url: videoURL)
        }

        filteringGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            Log.standard("[STUDIO] Merge started...")
            mergeAndExport()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard isPlayerSetup == false else {
            return
        }
        // INFO: Prevent wrong player frame size
        if let url = clipsManager.inputVideoURLs.first {
            setupPlayer(with: url)
        } else {
            Log.error("[STUDIO] Can't load initial video into player")
        }
    }
    
    // MARK: - Setup
    
    private func setupExport() {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Export", style: .plain, target: self, action: #selector(onExport))
    }
    
    private func setupStackView() {
        
        stackView = UIStackView()
        stackView.axis = .vertical
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin)
        }
    }
    
    private func setupClips() {
        
        let selectedVideoView = UIView()
        stackView.addArrangedSubview(selectedVideoView)
        selectedVideoView.snp.makeConstraints { make in
            make.height.equalTo(StudioViewController.fixedPanelsHeight)
        }
        
        let clipsViewController = ClipsViewController(delegate: self, clipsManager: clipsManager)
        add(child: clipsViewController, containerView: selectedVideoView)
    }
    
    private func setupPreview() {
        
        previewView = UIView()
        stackView.addArrangedSubview(previewView)
        
        let previewViewController = PreviewViewController()
        add(child: previewViewController, containerView: previewView)
    }
    
    private func setupFilters() {
        
        let filtersView = UIView()
        stackView.addArrangedSubview(filtersView)
        filtersView.snp.makeConstraints { make in
            make.height.equalTo(StudioViewController.fixedPanelsHeight)
        }
        
        let filtersViewController = FiltersViewController(delegate: self, filtersManager: filtersManager)
        add(child: filtersViewController, containerView: filtersView)
    }
    
    private func setupStatus() {
        
        let statusView = UIView()
        stackView.addArrangedSubview(statusView)
        statusView.snp.makeConstraints { make in
            make.height.equalTo(statusPanelHeight)
        }
        
        let statusViewController = StatusViewController()
        add(child: statusViewController, containerView: statusView)
        
        statusViewController.view.backgroundColor = .green
    }
    
    private func setupPlayerView() {
        
        playerView = UIView()
        previewView.addSubview(playerView)
        playerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        view.layoutIfNeeded()
    }
    
    private func setupPlayer(with url: URL) {
        
        let asset = AVAsset(url: url)
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
    
    // MARK: - Actions
    
    private func applyFilterAndExport(url: URL) {
        
        guard selectedFilterIndex != 0  else {
            clipsManager.outputVideoURLs.append(url)
            Log.standard("[STUDIO] Use original video at:\n\(url)")
            DispatchQueue.main.async { [weak self] in
                self?.setupPlayer(with: url)
            }
            return
        }
        
        // TODO: Move to FilterManager (currently it's toughly bounded to StudioViewController)
        
        filteringGroup.enter()
        
        let selectedImageFilter = self.filtersManager.filters[selectedFilterIndex]
        
        guard let filter = selectedImageFilter.filter else {
            Log.error("[STUDIO] Cannot retrieve filter")
            return
        }
        
        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        let videoComposition = AVMutableVideoComposition(asset: asset) { [weak self] request in
            guard let self = self else { return }
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
        exporter?.outputFileType = AVFileType(rawValue: Constants.outputFileType)
        
        let outputURL = localFileManager.fileURL(fileName: "\(url.fileName).\(selectedImageFilter.rawValue)", fileFormat: url.pathExtension)
        exporter?.outputURL = outputURL
        
        exporter?.exportAsynchronously(completionHandler: { [weak self] in
            guard let self = self, exporter?.status == .completed else {
                Log.error("[STUDIO] Export failed: \(exporter?.error)")
                return
            }
            clipsManager.outputVideoURLs.append(outputURL)
            Log.standard("[STUDIO] Export filtered video done:\n\(outputURL)")
            
            DispatchQueue.main.async { [weak self] in
                // TODO: Pass item instead of url?
                // TODO: Avoid blink from player switching
                self?.setupPlayer(with: outputURL)
            }
            
            self.filteringGroup.leave()
        })
    }
    
    private func mergeAndExport() {
        
        let assets = clipsManager.outputVideoURLs.map({ AVAsset(url: $0) })
        mergeManager.merge(arrayVideos: assets) { [weak self] mergedVideoURL, error in
            if let error = error {
                Log.error("[STUDIO] Merge failed:\n\(error)")
            } else if let mergedVideoURL = mergedVideoURL {
                Log.standard("[STUDIO] Merge done:\n\(mergedVideoURL)")
            } else {
                Log.error("[STUDIO] Merged video url creating failed")
            }
        }
    }
    
    @objc private func onExport(_ sender: Any) {
        
    }
    
    deinit {
        // TODO: Remove added child view controllers?
    }
}


// MARK: FiltersViewControllerDelegate

extension StudioViewController: FiltersViewControllerDelegate {
    
    func didSelectFilter(newIndex: Int) {
        selectedFilterIndex = newIndex
    }
}


// MARK: SelectedVideoViewControllerDelegate

extension StudioViewController: ClipsViewControllerDelegate {
    
    func didSelectVideo(newIndex: Int) {
        selectedVideoIndex = newIndex
    }
}
