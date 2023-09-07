//
//  DeleteEntryService.swift
//  dropbox-client
//
//  Created by Anton Chuev on 07.09.2023.
//

import SwiftyDropbox

protocol DeleteEntryService {
    func delete(at path: String, completion: @escaping (Files.DeleteResult?, CallError<Files.DeleteError>?) -> Void)
}

struct DefaultDeleteEnryService: DeleteEntryService {
    func delete(at path: String, completion: @escaping (Files.DeleteResult?, CallError<Files.DeleteError>?) -> Void) {
        let client = DropboxClientsManager.authorizedClient
        client?.files.deleteV2(path: path).response {
            completion($0, $1)
        }
    }
}
