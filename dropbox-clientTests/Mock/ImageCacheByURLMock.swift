//
//  ImageCacheByURLMock.swift
//  dropbox-clientTests
//
//  Created by Anton Chuev on 06.09.2023.
//

import Foundation

@testable import dropbox_client
import UIKit

final class ImageCacheByURLMock: ImageCacheByURLType {
    
    func image(for url: URL) -> UIImage? {
        return nil
    }
    
    func insertImage(_ image: UIImage?, for url: URL) {
        
    }
    
    func removeImage(for url: URL) {
        
    }
    
    func removeAllImages() {
        
    }
    
    subscript(url: URL) -> UIImage? {
        get {
            image(for: url)
        }
        set(newValue) {
            insertImage(newValue, for: url)
        }
    }
    
}
