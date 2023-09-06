//
//  ThumbnailCacheManager.swift
//  dropbox-client
//
//  Created by Anton Chuev on 04.09.2023.
//

import UIKit

protocol ImageCacheCleanerType: AnyObject {
    // Removes all images from the cache
    func removeAllImages()
}

// Declares in-memory image cache
protocol ImageCacheByURLType: AnyObject, ImageCacheCleanerType {
    // Returns the image associated with a given url
    func image(for url: URL) -> UIImage?
    // Inserts the image of the specified url in the cache
    func insertImage(_ image: UIImage?, for url: URL)
    // Removes the image of the specified url in the cache
    func removeImage(for url: URL)
    // Accesses the value associated with the given key for reading and writing
    subscript(_ url: URL) -> UIImage? { get set }
}


protocol ImageCacheByIDType: AnyObject, ImageCacheCleanerType {
    // Returns the image associated with a given id
    func image(for id: String) -> UIImage?
    // Inserts the image of the specified id in the cache
    func insertImage(_ image: UIImage?, for id: String)
    // Removes the image of the specified id in the cache
    func removeImage(for id: String)
    // Accesses the value associated with the given key for reading and writing
    subscript(_ id: String) -> UIImage? { get set }
}

final class ImageCache {
    
    // 1st level cache, that contains encoded images
    private lazy var imageCache: NSCache<AnyObject, AnyObject> = {
        let cache = NSCache<AnyObject, AnyObject>()
        cache.countLimit = config.countLimit
        return cache
    }()
    // 2nd level cache, that contains decoded images
    private lazy var decodedImageCache: NSCache<AnyObject, AnyObject> = {
        let cache = NSCache<AnyObject, AnyObject>()
        cache.totalCostLimit = config.memoryLimit
        return cache
    }()
    
    private let config: Config
    
    public struct Config {
        public let countLimit: Int
        public let memoryLimit: Int
        
        public static let defaultConfig = Config(countLimit: 100, memoryLimit: 1024 * 1024 * 100) // 100 MB
    }
    
    public init(config: Config = Config.defaultConfig) {
        self.config = config
    }
}

extension ImageCache: ImageCacheByURLType {
    func image(for url: URL) -> UIImage? {
        // the best case scenario -> there is a decoded image in memory
        if let decodedImage = decodedImageCache.object(forKey: url as AnyObject) as? UIImage {
            return decodedImage
        }
        // search for image data
        if let image = imageCache.object(forKey: url as AnyObject) as? UIImage {
            let decodedImage = image.decodedImage()
            decodedImageCache.setObject(image as AnyObject, forKey: url as AnyObject, cost: decodedImage.diskSize)
            return decodedImage
        }
        return nil
    }

    func insertImage(_ image: UIImage?, for url: URL) {
        guard let image = image else { return removeImage(for: url) }
        let decompressedImage = image.decodedImage()

        imageCache.setObject(decompressedImage, forKey: url as AnyObject, cost: 1)
        decodedImageCache.setObject(image as AnyObject, forKey: url as AnyObject, cost: decompressedImage.diskSize)
    }

    func removeImage(for url: URL) {
        imageCache.removeObject(forKey: url as AnyObject)
        decodedImageCache.removeObject(forKey: url as AnyObject)
    }

    subscript(_ key: URL) -> UIImage? {
        get {
            return image(for: key)
        }
        set {
            return insertImage(newValue, for: key)
        }
    }
}

extension ImageCache: ImageCacheCleanerType {
    func removeAllImages() {
        imageCache.removeAllObjects()
        decodedImageCache.removeAllObjects()
    }
}

extension ImageCache: ImageCacheByIDType {
    func image(for id: String) -> UIImage? {
        // the best case scenario -> there is a decoded image in memory
        if let decodedImage = decodedImageCache.object(forKey: id as AnyObject) as? UIImage {
            return decodedImage
        }
        // search for image data
        if let image = imageCache.object(forKey: id as AnyObject) as? UIImage {
            let decodedImage = image.decodedImage()
            decodedImageCache.setObject(image as AnyObject, forKey: id as AnyObject, cost: decodedImage.diskSize)
            return decodedImage
        }
        return nil
    }
    
    func insertImage(_ image: UIImage?, for id: String) {
        guard let image = image else { return removeImage(for: id) }
        let decompressedImage = image.decodedImage()

        imageCache.setObject(decompressedImage, forKey: id as AnyObject, cost: 1)
        decodedImageCache.setObject(image as AnyObject, forKey: id as AnyObject, cost: decompressedImage.diskSize)
    }
    
    func removeImage(for id: String) {
        imageCache.removeObject(forKey: id as AnyObject)
        decodedImageCache.removeObject(forKey: id as AnyObject)
    }
    
    subscript(key: String) -> UIImage? {
        get {
            return image(for: key)
        }
        set {
            return insertImage(newValue, for: key)
        }
    }
}

fileprivate extension UIImage {

    func decodedImage() -> UIImage {
        guard let cgImage = cgImage else { return self }
        let size = CGSize(width: cgImage.width, height: cgImage.height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: cgImage.bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        context?.draw(cgImage, in: CGRect(origin: .zero, size: size))
        guard let decodedImage = context?.makeImage() else { return self }
        return UIImage(cgImage: decodedImage)
    }

    // Rough estimation of how much memory image uses in bytes
    var diskSize: Int {
        guard let cgImage = cgImage else { return 0 }
        return cgImage.bytesPerRow * cgImage.height
    }
}
