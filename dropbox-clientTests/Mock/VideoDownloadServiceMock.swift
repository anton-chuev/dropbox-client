//
//  VideoDownloadServiceMock.swift
//  dropbox-clientTests
//
//  Created by Anton Chuev on 06.09.2023.
//

@testable import dropbox_client
import Foundation

final class VideoDownloadServiceMock {
    var downloadVideoGotCalled = false
    var completeClosure: ((URL?) -> Void)!
    
    func downloadVideoSuccess() {
        completeClosure(URL(string: "some/local/url")!)
    }
        
    func downloadVideoFail() {
        completeClosure(nil)
    }
}

extension VideoDownloadServiceMock: VideoDownloadService {
    func downloadVideo(from url: URL, completion: @escaping (URL?) -> Void) {
        downloadVideoGotCalled = true
        completeClosure = completion
    }
}
