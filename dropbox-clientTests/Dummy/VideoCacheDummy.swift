//
//  VideoCacheDummy.swift
//  dropbox-clientTests
//
//  Created by Anton Chuev on 06.09.2023.
//

@testable import dropbox_client
import Foundation

final class VideoCacheDummy: VideoCacheType {
    func video(for url: URL) -> URL? {
        return nil
    }
    
    func insertVideo(to url: URL, from tempURL: URL) {
        
    }
    
    func removeVideo(for url: URL) {
        
    }
    
    func removeAllVideos() {
        
    }
    
    var videoCacheDirectory: URL { return getDocumentsDirectory() }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}
