//
//  ImageViewerViewModel.swift
//  dropbox-client
//
//  Created by Anton Chuev on 05.09.2023.
//

import Foundation
import UIKit

final class ImageViewerViewModel {
    
    // MARK: - Observables
    private(set) var errorMessage = Observable<String?>(nil)
    private(set) var isLoading = Observable<Bool>(false)
    private(set) var image = Observable<UIImage?>(nil)
    private(set) var entryInfo = Observable<String?>(nil)
    
    // MARK: - Private properties
    private var entry: FileMetadata
    private var contentLinkService: ContentLinkService
    private var imageDataDownloadService: ImageDataDownloadService
    private var imageCache: ImageCacheByURLType
    
    init(entry: FileMetadata,
         contentLinkService: ContentLinkService,
         imageDataDownloadService: ImageDataDownloadService,
         imageCache: ImageCacheByURLType) {
        self.entry = entry
        self.contentLinkService = contentLinkService
        self.imageDataDownloadService = imageDataDownloadService
        self.imageCache = imageCache
    }
    
    // MARK: - Intentions
    func viewDidLoad() {
        entryInfo.value = EntryPrettyInfoStringComposer.prettyString(from: entry)
        isLoading.value = true
    }
    
    func fetchData() {
        getContentLink()
    }
    
    // MARK: - Helping methods
    func cleanImageCache() {
        imageCache.removeAllImages()
    }
    
    // MARK: - Private
    private func getContentLink() {
        if
            let link = entry.contentLink,
            let url = URL(string: link),
            let image = imageCache[url]
        {
            image.prepareForDisplay { [weak self] decodedImage in
                self?.image.value = decodedImage
                self?.isLoading.value = false
            }
            return
        }
        
        
        contentLinkService.getContentLink(of: entry) { [weak self] result, error in
            if let error = error {
                // TODO: Add proper error handling
                self?.errorMessage.value = error.description
            } else if let result = result {
                // Update entry using reference semantic
                self?.entry.contentLink = result.link
                self?.downloadImageData(from: result.link)
            }
        }
    }
    
    private func downloadImageData(from link: String) {
        guard let url = URL(string: link) else {
            isLoading.value = false
            image.value = nil
            return
        }
        
        imageDataDownloadService.downloadData(from: url) { [weak self] data in
            if let data = data {
                UIImage(data: data)?.prepareForDisplay { decodedImage in
                    self?.image.value = decodedImage
                    self?.isLoading.value = false
                }
                
                self?.cacheImageData(data, for: url)
            } else {
                // TODO: Add proper error handling
                self?.errorMessage.value = "Failed loading image"
                self?.isLoading.value = false
            }
        }
    }
    
    private func cacheImageData(_ data: Data, for url: URL) {
        imageCache[url] = UIImage(data: data)
    }
}
