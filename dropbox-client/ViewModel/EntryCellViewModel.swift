//
//  EntryCellViewModel.swift
//  dropbox-client
//
//  Created by Anton Chuev on 03.09.2023.
//

import SwiftyDropbox
import UIKit

final class EntryCellViewModel {
    private(set) var thumbnailURL = Observable<String?>(nil)
    private(set) var imageData = Observable<Data?>(nil)
    private(set) var entryName = Observable<String?>(nil)
    
    private var thumbnailService: ThumbnailService
    private var metadata: Metadata
    private(set) var thumbnailCache: ImageCacheByIDType
    
    init(metadata: Metadata, thumbnailService: ThumbnailService, thumbnailCache: ImageCacheByIDType) {
        self.thumbnailService = thumbnailService
        self.metadata = metadata
        self.thumbnailCache = thumbnailCache
    }
    
    func initialSetup() {
        entryName.value = metadata.name
        let image = metadata.isFolder ? UIImage(systemName: "folder.circle") : UIImage(systemName: "photo.circle")
        imageData.value = image?.withTintColor(.blue, renderingMode: .alwaysTemplate).pngData()
    }
    
    func getThumbnail() {
        guard
            let fileMetadata = metadata as? FileMetadata,
            let path = fileMetadata.pathLower else
        { return }
        
        if let image = thumbnailCache[fileMetadata.id] {
            print("Image from cache for \(fileMetadata.id)")
            self.imageData.value = image.pngData()
            return
        }
        
        thumbnailService.thumbnail(for: path) { [weak self] previewResultAndData, error in
            // TODO: Add proper error handling
            if let previewResultAndData = previewResultAndData {
                let fileMetadataDTO: Files.FileMetadata = previewResultAndData.0
                
                // Update file from FolderContentViewModel
                let receivedFileMetadata = fileMetadataDTO.toFileMetadata()
                fileMetadata.mediaMetadata = receivedFileMetadata.mediaMetadata

                let data = previewResultAndData.1
                self?.imageData.value = data
                self?.thumbnailCache[fileMetadata.id] = UIImage(data: data)
            }
        }
    }
    
}
