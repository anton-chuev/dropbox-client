//
//  ImageDataDownloadService.swift
//  dropbox-client
//
//  Created by Anton Chuev on 01.09.2023.
//

import Foundation

protocol ImageDataDownloadService {
    func downloadData(from url: URL, completion: @escaping (Data?) -> Void)
}

struct DefaultImageDataService: ImageDataDownloadService {
    func downloadData(from url: URL, completion: @escaping (Data?) -> Void) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                completion(data)
            } else {
                completion(nil)
            }
        }
    }
}
