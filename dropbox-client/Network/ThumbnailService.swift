//
//  ThumbnailService.swift
//  dropbox-client
//
//  Created by Anton Chuev on 03.09.2023.
//

import SwiftyDropbox
import Foundation

protocol ThumbnailService {
    func thumbnail(for path: String, completion: @escaping ((Files.FileMetadata, Data)?, CallError<Files.ThumbnailError>?) -> Void)
}

struct DefaultThumbnailService: ThumbnailService {

    func thumbnail(for path: String, completion: @escaping ((Files.FileMetadata, Data)?, CallError<Files.ThumbnailError>?) -> Void) {
        let client = DropboxClientsManager.authorizedClient
        client?.files.getThumbnail(path: path).response(completionHandler: { preViewAndData, error in
            completion(preViewAndData, error)
        })
    }
    
}
