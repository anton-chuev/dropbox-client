//
//  FolderContentService.swift
//  dropbox-client
//
//  Created by Anton Chuev on 31.08.2023.
//

import SwiftyDropbox

protocol FolderContentService {
    func fetchContent(at path: String, limit: UInt32?, completion: @escaping (Files.ListFolderResult?, CallError<Files.ListFolderError>?) -> Void)
    func continueFetchingContent(from cursor:String, completion: @escaping (Files.ListFolderResult?, CallError<Files.ListFolderContinueError>?) -> Void)
}

struct DefaultFolderContentService: FolderContentService {
    
    func fetchContent(at path: String, limit: UInt32?, completion: @escaping (Files.ListFolderResult?, CallError<Files.ListFolderError>?) -> Void) {
        let client = DropboxClientsManager.authorizedClient
        client?.files.listFolder(path: path, limit: limit).response(completionHandler: {
            completion($0, $1)
        })
    }
    
    func continueFetchingContent(from cursor: String, completion: @escaping (Files.ListFolderResult?, CallError<Files.ListFolderContinueError>?) -> Void) {
        let client = DropboxClientsManager.authorizedClient
        client?.files.listFolderContinue(cursor: cursor).response {
            completion($0, $1)
        }
    }

}
