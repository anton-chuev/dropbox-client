//
//  MetadataService.swift
//  dropbox-client
//
//  Created by Anton Chuev on 02.09.2023.
//

import SwiftyDropbox

protocol MetadataService {
    func metadataOfEntry(at path: String, completion: @escaping (Files.Metadata?, CallError<Files.GetMetadataError>?) -> Void)
}

struct DefaultMetadataService: MetadataService {
    func metadataOfEntry(at path: String, completion: @escaping (Files.Metadata?, CallError<Files.GetMetadataError>?) -> Void) {
        let client = DropboxClientsManager.authorizedClient
        client?.files.getMetadata(path: path, includeMediaInfo: true).response(completionHandler: {
            completion($0, $1)
        })
    }
}
