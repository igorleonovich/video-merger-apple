//
//  LocalFileManager.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 02/10/2023.
//

import Foundation

final class LocalFileManager {
    
    private func defaultFileDirectory() -> URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls.first!
    }

    func removeFile(fileName: String, fileFormat: String) throws {
        guard isFileExist(fileName: fileName, fileFormat: fileFormat) else {
            return
        }
        let fileURL = self.fileURL(fileName: fileName, fileFormat: fileFormat)
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            throw NSErrorDomain.init(string: "[LOCAL FILE MANAGER] Unable to remove data") as! Error
        }
    }
    
    func removeFileIfExisted(_ url: URL) -> Void {
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(atPath: url.path)
            }
            catch {
                Log.error("[LOCAL FILE MANAGER] Failed to delete file")
            }
        }
    }
    
    func removeAllFiles() throws {
        let documentsUrl =  self.defaultFileDirectory()
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsUrl,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: [])
            for fileURL in fileURLs {
                try FileManager.default.removeItem(at: fileURL)
            }
        } catch  {
            throw NSErrorDomain.init(string: "[LOCAL FILE MANAGER] Unable to remove all data") as! Error
        }
    }

    func isFileExist(fileName: String, fileFormat: String) -> Bool {
        let fileURL = self.fileURL(fileName: fileName, fileFormat: fileFormat)
        let exists = FileManager.default.fileExists(atPath: fileURL.path)
        return exists
    }

    func fileURL(fileName: String, fileFormat: String) -> URL {
        return self.defaultFileDirectory().appendingPathComponent(fileName).appendingPathExtension(fileFormat)
    }
}

