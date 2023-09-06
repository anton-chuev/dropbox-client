//
//  ImageDataDownloadServiceMock.swift
//  dropbox-clientTests
//
//  Created by Anton Chuev on 06.09.2023.
//

@testable import dropbox_client
import Foundation
import UIKit

final class ImageDataDownloadServiceMock {
    var downloadImageDataGotCalled = false
    var completeClosure: ((Data?) -> Void)!
    
    func imageDataDownloadSuccess() {
        completeClosure(UIImage(systemName: "info")!.pngData())
    }
        
    func imageDataDownloadFail(error: Error?) {
        completeClosure(nil)
    }
}

extension ImageDataDownloadServiceMock: ImageDataDownloadService {
    func downloadData(from url: URL, completion: @escaping (Data?) -> Void) {
        downloadImageDataGotCalled = true
        completeClosure = completion
    }
}
