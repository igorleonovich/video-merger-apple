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
    
    private var clipsViewController: ClipsViewController!
    private var filtersViewController: FiltersViewController!
    private var statusViewController: StatusViewController!
    
    private var stackView: UIStackView!
    private var previewView: UIView!
    private var thumbnailView: UIImageView!
    private var filtersView: UIView!
    private var overlayView: UIView!
    private let statusPanelHeight: CGFloat = 50
    
    private var player: AVQueuePlayer!
    private var videoLooper: AVPlayerLooper!
    private var playerView: UIView!
    private var playerLayer: AVPlayerLayer!
    private var isPlayerSetup = false
    
    private var selectedVideoIndex = 0 {
        didSet {
            updateThumbnail { [weak self] image in
                self?.thumbnailView.image = image
                self?.prefilterCurrentVideo()
            }
            filtersViewController.currentVideoUrl = clipsManager.inputVideoURLs[selectedVideoIndex]
            filtersViewController.collectionView.reloadData()
            print(selectedVideoIndex)
        }
    }
    private var selectedFilterIndex = 0 {
        didSet {
            if studioState == .exported, oldValue != selectedFilterIndex {
                studioState = .ready
            }
            filtersManager.selectedFilterIndex = selectedFilterIndex
            updateThumbnail { [weak self] image in
                self?.thumbnailView.image = image
                self?.prefilterCurrentVideo()
                self?.clipsViewController.collectionView.reloadData()
            }
            clipsViewController.collectionView.reloadData()
            print(selectedFilterIndex)
        }
    }
    
    private var studioState: StudioState = .loading {
        didSet {
            statusViewController.update(with: studioState.rawValue)
            switch studioState {
            case .loading:
                break
            case .ready:
                overlayView.alpha = 0
                setupExportButton()
            case .prefiltering:
                overlayView.alpha = 0.75
                // TODO: Show Export button instead of Cancel (need to add Cancel functionality for that)
                setupCancelButton()
            case .filtering:
                overlayView.alpha = 0.75
                setupCancelButton()
            case .merging:
                break
            case .exported:
                overlayView.alpha = 0
                clipsManager.outputVideoURLs.removeAll()
                setupExportButton()
            }
        }
    }
    
    private var filterAndMergeGroup: DispatchGroup!
    
    
    // MARK: Life cycle
    
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
        
        setupStackView()
        
        setupClips()
        setupPreview()
        setupFilters()
        setupStatus()
        
        setupPlayerView()
        setupThumbnail()
        
        setupOverlay()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // INFO: Prevent wrong player frame size
        guard isPlayerSetup == false else {
            return
        }
        if let url = clipsManager.inputVideoURLs.first {
            isPlayerSetup = true
            DispatchQueue.main.async { [weak self] in
                self?.setupPlayer(with: url)
                self?.selectedVideoIndex = 0
            }
        } else {
            Log.error("[STUDIO] Can't load initial video into player")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if studioState == .loading {
            studioState = .ready
        }
    }
    
    
    // MARK: Setup
    
    private func setupExportButton() {
        let exportButton = UIBarButtonItem(title: "Export".uppercased(), style: .plain, target: self, action: #selector(onExport(_:)))
        navigationItem.rightBarButtonItem = exportButton
    }
    
    private func setupCancelButton() {
        let cancelButton = UIBarButtonItem(title: "Cancel".uppercased(), style: .plain, target: self, action: #selector(onCancel(_:)))
        navigationItem.rightBarButtonItem = cancelButton
    }
    
    private func setupStackView() {
        
        stackView = UIStackView()
        stackView.axis = .vertical
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(15)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin)
        }
    }
    
    private func setupClips() {
        
        let clipsView = UIView()
        stackView.addArrangedSubview(clipsView)
        clipsView.snp.makeConstraints { make in
            make.height.equalTo(CollectionViewController.cellSide)
        }
        
        clipsViewController = ClipsViewController(delegate: self, clipsManager: clipsManager, filtersManager: filtersManager,
                                                  localFileManager: localFileManager)
        add(child: clipsViewController, containerView: clipsView)
    }
    
    private func setupPreview() {
        
        previewView = UIView()
        stackView.addArrangedSubview(previewView)
        
        let previewViewController = PreviewViewController()
        add(child: previewViewController, containerView: previewView)
    }
    
    private func setupFilters() {
        
        filtersView = UIView()
        stackView.addArrangedSubview(filtersView)
        filtersView.snp.makeConstraints { make in
            make.height.equalTo(150)
        }
        
        filtersViewController = FiltersViewController(delegate: self, filtersManager: filtersManager, localFileManager: localFileManager)
        add(child: filtersViewController, containerView: filtersView)
        
        filtersViewController.currentVideoUrl = clipsManager.inputVideoURLs[selectedVideoIndex]
    }
    
    private func setupStatus() {
        
        let statusView = UIView()
        stackView.addArrangedSubview(statusView)
        statusView.snp.makeConstraints { make in
            make.height.equalTo(statusPanelHeight)
        }
        
        statusViewController = StatusViewController(delegate: self)
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

    
    private func setupThumbnail() {
        
        thumbnailView = UIImageView()
        view.addSubview(thumbnailView)
        thumbnailView.snp.makeConstraints { make in
            make.edges.equalTo(previewView)
        }
        thumbnailView.contentMode = .scaleAspectFill
        thumbnailView.clipsToBounds = true
    }
    
    private func setupOverlay() {
        
        overlayView = UIView()
        view.addSubview(overlayView)
        overlayView.snp.makeConstraints { make in
            make.top.equalTo(stackView)
            make.left.equalTo(stackView)
            make.right.equalTo(stackView)
            make.bottom.equalTo(filtersView)
        }
        overlayView.backgroundColor = .black
        overlayView.alpha = 0
    }
    
    
    // MARK: Actions
    
    // TODO: Move Filtering and Merge functions to managers (currently it's toughly bounded to StudioViewController)
    private func prefilterCurrentVideo() {
        filterVideo(inputVideoURLs: [clipsManager.inputVideoURLs[selectedVideoIndex]], isPrefiltering: true) { [weak self] in
            guard let self = self else { return }
            self.thumbnailView.image = nil
            if self.studioState == .prefiltering {
                self.studioState = .ready
            }
        }
    }
    
    private func filterVideo(inputVideoURLs: [URL], isPrefiltering: Bool = false, completion: @escaping () -> Void) {
        /* INFO: Applying filter before merge for displaying it in preview and for avoiding filtering of added black space in case of different aspect ratio */
        
        let selectedImageFilter = filtersManager.filters[selectedFilterIndex]
        
        if isPrefiltering, let url = inputVideoURLs.first {
            
            studioState = .prefiltering
            Log.standard("[STUDIO] Pre-Filtering started...")
            
            let outputURL = localFileManager.fileURL(fileName: "\(url.fileName).\(selectedImageFilter.title.lowercased())",
                                                     fileFormat: url.pathExtension)
            
            guard !FileManager.default.fileExists(atPath: outputURL.path) else {
                setupPlayer(with: outputURL)
                completion()
                return
            }
        } else {
            studioState = .filtering
            Log.standard("[STUDIO] Filtering started...")
        }

        filterAndMergeGroup = DispatchGroup()

        inputVideoURLs.forEach { url in
            
            let outputURL = localFileManager.fileURL(fileName: "\(url.fileName).\(selectedImageFilter.title.lowercased())",
                                                     fileFormat: url.pathExtension)
            
            guard selectedFilterIndex != 0  else {
                clipsManager.outputVideoURLs.append(url)
                Log.standard("[STUDIO] Use original video at:\n\(url)")
                DispatchQueue.main.async { [weak self] in
                    self?.setupPlayer(with: url)
                }
                return
            }
            
            guard !FileManager.default.fileExists(atPath: outputURL.path) else {
                clipsManager.outputVideoURLs.append(url)
                Log.standard("[STUDIO] Use already filtered video at:\n\(outputURL)")
                return
            }
            
            // TODO: Move to FilterManager (currently it's toughly bounded to StudioViewController)
            
            filterAndMergeGroup.enter()
            
            let asset = AVAsset(url: url)
            let item = AVPlayerItem(asset: asset)
            let videoComposition = AVMutableVideoComposition(asset: asset) { [weak self] request in
                guard let self = self else { return }
                let source = request.sourceImage.clampedToExtent()
                
                let outputImage = self.filtersManager.apply(selectedImageFilter.filter, for: source)
                
                request.finish(with: outputImage, context: nil)
            }
            item.videoComposition = videoComposition

            let exporter = AVAssetExportSession(asset: item.asset, presetName: AVAssetExportPresetHighestQuality)
            exporter?.videoComposition = videoComposition
            exporter?.outputFileType = AVFileType(rawValue: Constants.outputFileType)
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
                
                self.filterAndMergeGroup.leave()
            })
        }

        filterAndMergeGroup.notify(queue: .main) {
            completion()
        }
    }
    
    private func mergeAndExportVideo(_ completion: @escaping (URL?) -> Void) {
        
        let assets = clipsManager.outputVideoURLs.map({ AVAsset(url: $0) })
        
        mergeManager.merge(arrayVideos: assets) { [weak self] mergedVideoURL, error in
            if let error = error {
                Log.error("[STUDIO] Merge failed:\n\(error)")
                completion(nil)
                self?.studioState = .ready
                
            } else if let mergedVideoURL = mergedVideoURL {
                Log.standard("[STUDIO] Merge done:\n\(mergedVideoURL)")
                completion(mergedVideoURL)
                self?.studioState = .exported
                
            } else {
                Log.error("[STUDIO] Merged video url creating failed")
                completion(nil)
                self?.studioState = .ready
            }
        }
    }
    
    private func showExport(with url: URL) {
        
        let exportViewController = ExportViewController(url: url)
        exportViewController.modalPresentationStyle = .pageSheet
        exportViewController.modalTransitionStyle = .coverVertical
        present(exportViewController, animated: true)
    }
    
    @objc private func onExport(_ sender: Any) {
        
        onExport()
    }
    
    private func onExport() {
        
        if studioState == .exported, let mergedURL = mergeManager.mergedURL {
            showExport(with: mergedURL)
        } else {
            filterVideo(inputVideoURLs: clipsManager.inputVideoURLs) { [weak self] in
                guard let self = self else { return }
                studioState = .merging
                Log.standard("[STUDIO] Merge started...")
                mergeAndExportVideo { [weak self] mergedURL in
                    if let mergedURL = mergedURL {
                        self?.showExport(with: mergedURL)
                    }
                }
            }
        }
    }
    
    @objc private func onCancel(_ sender: Any) {
        
    }
    
    
    // MARK: Updates
    
    private func updateThumbnail(_ completion: @escaping (UIImage?) -> Void) {
        filtersManager.applyThumbnail(with: clipsManager.inputVideoURLs[selectedVideoIndex],
                                 imageFilter: filtersManager.filters[selectedFilterIndex],
                                 filtersManager: filtersManager,
                                 localFileManager: localFileManager,
                                      completion: completion)
    }
}


// MARK: StudioViewControllerDelegate

extension StudioViewController: StatusViewControllerDelegate {
    
    func didTapStatus() {
        switch studioState {
        case .exported:
            onExport()
        default:
            break
        }
    }
}


// MARK: ClipsViewControllerDelegate

extension StudioViewController: ClipsViewControllerDelegate {
    
    func didSelectVideo(newIndex: Int) {
        selectedVideoIndex = newIndex
    }
}


// MARK: FiltersViewControllerDelegate

extension StudioViewController: FiltersViewControllerDelegate {
    
    func didSelectFilter(newIndex: Int) {
        selectedFilterIndex = newIndex
    }
}
