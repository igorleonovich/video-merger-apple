//
//  PickerViewController.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 02/10/2023.
//

import PhotosUI
import ProgressHUD
import UIKit

final class PickerViewController: BaseViewController {
    
    private weak var localFileManager: LocalFileManager!
    
    private var savingLocallyGroup: DispatchGroup!
    private var videoURLs = [URL]()
    private var filenameDuplicationsCounter = 0
    
    private var picker: PHPickerViewController?
    
    // MARK: Life Cycle
    
    init(localFileManager: LocalFileManager) {
        super.init()
        self.localFileManager = localFileManager
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showPickerIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showPickerIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    private func showPickerIfNeeded() {
        
        guard picker == nil else {
            return
        }
        
        do {
            var config = PHPickerConfiguration()
            
            config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
            config.selectionLimit = Constants.maxVideoFilesCount
            
            config.filter = .videos
            let picker = PHPickerViewController(configuration: config)
            self.picker = picker
            
            picker.modalPresentationStyle = .overFullScreen
            picker.modalTransitionStyle = .crossDissolve
            picker.delegate = self
            
            present(picker, animated: true) {
                Log.standard("[PICKER] Picker opened")
            }
        }
    }
    
    // MARK: Actions
    
    fileprivate func saveVideoLocally(_ result: PHPickerResult) {
        
        savingLocallyGroup.enter()
        
        let movie = UTType.movie.identifier // "com.apple.quicktime-movie"
        let itemProvider = result.itemProvider

        itemProvider.loadFileRepresentation(forTypeIdentifier: movie) { [weak self] externalURL, err in
            guard let self = self else { return }
            if let externalURL = externalURL {
                DispatchQueue.global().sync {
                    guard let localURL = self.saveFile(externalURL: externalURL) else { return }
                    self.videoURLs.append(localURL)
                }
            }
            self.savingLocallyGroup.leave()
        }
    }
    
    private func saveFile(externalURL: URL) -> URL? {
        
        do {
            var localURL = localFileManager.fileURL(fileName: externalURL.fileName, fileFormat: externalURL.pathExtension)
            if localFileManager.isFileExist(fileName: localURL.fileName, fileFormat: localURL.pathExtension) {
                localURL = urlWithChangedName(url: externalURL)
            }
            
            try FileManager.default.copyItem(at: externalURL, to: localURL)
            Log.standard("[PICKER] Saved locally at:\n\(localURL)")
            
            return localURL
        } catch {
            DispatchQueue.main.async { [weak self] in
                let alert = UIAlertController(title: "main.alert.error.getting.file".localize, message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "button.ok".localize, style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }
        }
        
        return nil
    }
    
    // MARK: Helpers
    
    func urlWithChangedName(url: URL) -> URL {
        
        filenameDuplicationsCounter += 1
        let newFileName = "\(url.fileName)-\(filenameDuplicationsCounter)"
        
        return localFileManager.fileURL(fileName: newFileName, fileFormat: url.pathExtension)
    }
}


extension PickerViewController: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true) {
            
            ProgressHUD.show()
            
            DispatchQueue.global().sync { [weak self] in
                do {
                    try self?.localFileManager.removeAllFiles()
                } catch {
                    Log.error("[PICKER] Error:\n\(error)")
                }
            }
            
            DispatchQueue.main.async { [weak self] in
                
                guard let self = self else { return }
                self.savingLocallyGroup = DispatchGroup()
                
                results.forEach { result in
                    let itemProvider = result.itemProvider
                    if itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                        self.saveVideoLocally(result)
                    }
                }
                
                self.savingLocallyGroup.notify(queue: .main) { [weak self] in
                    
                    guard let self = self else { return }
                    let studioViewController = StudioViewController(videoURLs: self.videoURLs,
                                                                    localFileManager: localFileManager)
                    // COMMENT: Ideally it should be handled by router
                    self.navigationController?.pushViewController(studioViewController, animated: true)
                    
                    Log.standard("[PICKER] Picker has closed")
                    self.picker = nil
                    
                    ProgressHUD.dismiss()
                }
            }
        }
    }
}
