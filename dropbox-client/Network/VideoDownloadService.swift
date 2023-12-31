//
//  VideoDownloadService.swift
//  dropbox-client
//
//  Created by Anton Chuev on 02.09.2023.
//

import Foundation
import Alamofire

protocol VideoDownloadService {
    func downloadVideo(from url: URL, completion: @escaping (URL?) -> Void)
}

class DefaultVideoDownloadService: VideoDownloadService {
    
    func downloadVideo(from url: URL, completion: @escaping (URL?) -> Void) {
        let task = URLSession.shared.downloadTask(with: url) { (tempFileURL, response, error) in
            completion(tempFileURL)
        }
        task.resume()
    }
    
}
