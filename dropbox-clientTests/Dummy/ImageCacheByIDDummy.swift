//
//  ImageCacheByIDDummy.swift
//  dropbox-clientTests
//
//  Created by Anton Chuev on 06.09.2023.
//

@testable import dropbox_client
import UIKit

final class ImageCacheByIDDummy: ImageCacheByIDType {
    
    func image(for id: String) -> UIImage? {
        return nil
    }
    
    func insertImage(_ image: UIImage?, for id: String) {
        
    }
    
    func removeImage(for id: String) {
        
    }
    
    func removeAllImages() {
        
    }
    
    subscript(id: String) -> UIImage? {
        get {
            image(for: id)
        }
        set(newValue) {
            insertImage(newValue, for: id)
        }
    }
    
}
