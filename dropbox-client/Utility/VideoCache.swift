//
//  VideoCache.swift
//  dropbox-client
//
//  Created by Anton Chuev on 05.09.2023.
//

import AVFoundation

protocol VideoCacheType: AnyObject {
    func video(for url: URL) -> URL?
    func insertVideo(to url: URL, from tempURL: URL)
    func removeVideo(for url: URL)
    func removeAllVideos()
    var videoCacheDirectory: URL { get }
}

final class VideoCache {
    
    private var fileManager: FileManager { FileManager.default }
    
    init() {
        cleanOldFiles()
    }
    
    var videoCacheDirectory: URL {
        let cacheURL = getDocumentsDirectory().appendingPathComponent("Video")
        if !fileManager.fileExists(atPath: cacheURL.path) {
            try? fileManager.createDirectory(at: cacheURL, withIntermediateDirectories: false)
        }
        return cacheURL
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}

extension VideoCache: VideoCacheType {
    func video(for url: URL) -> URL? {
        return fileManager.fileExists(atPath: url.path) ? url : .none
    }
    
    func insertVideo(to url: URL, from tempURL: URL) {
        try? fileManager.moveItem(at: tempURL, to: url)
    }
    
    func removeVideo(for url: URL) {
        try? fileManager.removeItem(at: url)
    }
    
    func removeAllVideos() {
        try? fileManager.removeItem(at: videoCacheDirectory)
    }
}

private extension VideoCache {
    static private let maxLifetime: TimeInterval = 60*60*24
    
    func cleanOldFiles() {
        guard let urlArray =
            try? fileManager.contentsOfDirectory(at: videoCacheDirectory,
                                                 includingPropertiesForKeys: [.contentModificationDateKey],
                                                 options:.skipsHiddenFiles) else {
            return
        }
        
        urlArray.forEach { url in
            if
                let resourceValues = try? url.resourceValues(forKeys: [.contentModificationDateKey]),
                let modificationDate = resourceValues.contentModificationDate
            {
                let delta = Date() - modificationDate
                if delta > VideoCache.maxLifetime {
                    removeVideo(for: url)
                }
            }
        }
    }
}


fileprivate extension Date {

    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }

}
