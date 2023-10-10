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

    func removeFileIfExists(fileName: String, fileFormat: String) throws {
        
        guard isFileExists(fileName: fileName, fileFormat: fileFormat) else {
            return
        }
        let fileURL = fileURL(fileName: fileName, fileFormat: fileFormat)
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            throw NSErrorDomain.init(string: "[LOCAL FILE MANAGER] Unable to remove file") as! Error
        }
    }
    
    func removeFileIfExists(_ url: URL) -> Void {
        
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
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: defaultFileDirectory(),
                                                                       includingPropertiesForKeys: nil,
                                                                       options: [])
            for fileURL in fileURLs {
                try FileManager.default.removeItem(at: fileURL)
            }
        } catch  {
            throw NSErrorDomain.init(string: "[LOCAL FILE MANAGER] Unable to remove all files") as! Error
        }
    }

    func isFileExists(fileName: String, fileFormat: String) -> Bool {
        
        let fileURL = fileURL(fileName: fileName, fileFormat: fileFormat)
        return FileManager.default.fileExists(atPath: fileURL.path)
    }

    func fileURL(fileName: String, fileFormat: String) -> URL {
        
        return defaultFileDirectory().appendingPathComponent(fileName).appendingPathExtension(fileFormat)
    }
}
