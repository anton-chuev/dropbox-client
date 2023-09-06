//
//  VideoDownloadService.swift
//  dropbox-client
//
//  Created by Anton Chuev on 02.09.2023.
//

import Foundation
import Alamofire

protocol VideoDownloadService {
    func downloadVideo(from url: URL, completion: @escaping (URL?, Error?) -> Void)
    func cancelAllDownloads()
}

class DefaultVideoDownloadService: VideoDownloadService {
    private var activeDownloads = [URL: URLSessionDownloadTask]()
    private var lock = NSLock()
    
    func downloadVideo(from url: URL, completion: @escaping (URL?, Error?) -> Void) {
        let task = URLSession.shared.downloadTask(with: url) { (tempFileURL, response, error) in
            self.removeTask(for: url)
            completion(tempFileURL, error)
        }
        add(task, for: url)
        task.resume()
    }
    
    func cancelAllDownloads() {
        activeDownloads.values.forEach { $0.cancel() }
        removeAllTasks()
    }
    
    private func add(_ task: URLSessionDownloadTask, for key: URL) {
        lock.lock()
        activeDownloads[key] = task
        lock.unlock()
    }
    
    private func removeTask(for key: URL) {
        lock.lock()
        activeDownloads.removeValue(forKey: key)
        lock.unlock()
    }
    
    private func removeAllTasks() {
        lock.lock()
        activeDownloads.removeAll()
        lock.unlock()
    }
}
