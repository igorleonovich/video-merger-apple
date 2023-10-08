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
    
    private var statusViewController: StatusViewController!
    
    private var stackView: UIStackView!
    private var previewView: UIView!
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
            print(selectedVideoIndex)
        }
    }
    private var selectedFilterIndex = 0 {
        didSet {
            if studioState == .exported, oldValue != selectedFilterIndex {
                studioState = .ready
            }
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
    
    private var filteringGroup: DispatchGroup!
    
    
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
        
        setupOverlay()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // INFO: Prevent wrong player frame size
        guard isPlayerSetup == false else {
            return
        }
        if let url = clipsManager.inputVideoURLs.first {
            setupPlayer(with: url)
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
    
    private var exportButton: UIBarButtonItem {
        return UIBarButtonItem(title: "Export".uppercased(), style: .plain, target: self, action: #selector(onExport(_:)))
    }
    
    private var cancelButton: UIBarButtonItem {
        return UIBarButtonItem(title: "Cancel".uppercased(), style: .plain, target: self, action: #selector(onCancel))
    }
    
    private func setupExportButton() {
        navigationItem.rightBarButtonItem = exportButton
    }
    
    private func setupCancelButton() {
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
            make.height.equalTo(CollectionViewController.fixedPanelsHeight)
        }
        
        let clipsViewController = ClipsViewController(delegate: self, clipsManager: clipsManager)
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
            make.height.equalTo(CollectionViewController.fixedPanelsHeight)
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
        
        isPlayerSetup = true
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
        
        let outputURL = localFileManager.fileURL(fileName: "\(url.fileName).\(selectedImageFilter.title.lowercased())", fileFormat: url.pathExtension)
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
    
    private func mergeAndExport(_ completion: @escaping (URL?) -> Void) {
        
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
            /* INFO: Applying filter before merge for displaying it in preview and for avoiding filtering of added black space in case of different aspect ratio */
            studioState = .filtering
            Log.standard("[STUDIO] Filtering started...")

            filteringGroup = DispatchGroup()

            clipsManager.inputVideoURLs.forEach { videoURL in
                applyFilterAndExport(url: videoURL)
            }

            filteringGroup.notify(queue: .main) { [weak self] in
                guard let self = self else { return }
                studioState = .merging
                Log.standard("[STUDIO] Merge started...")
                mergeAndExport { [weak self] mergedURL in
                    if let mergedURL = mergedURL {
                        self?.showExport(with: mergedURL)
                    }
                }
            }
        }
    }
    
    @objc private func onCancel(_ sender: Any) {
        
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
