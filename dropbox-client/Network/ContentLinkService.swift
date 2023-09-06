//
//  ContentLinkService.swift
//  dropbox-client
//
//  Created by Anton Chuev on 31.08.2023.
//

import Foundation
import SwiftyDropbox

protocol ContentLinkService {
    func getContentLink(of entry: Metadata, completion: @escaping (Files.GetTemporaryLinkResult?, CallError<Files.GetTemporaryLinkError>?) -> Void)
}

struct DefaultContentLinkService: ContentLinkService {    
    func getContentLink(of entry: Metadata, completion: @escaping (Files.GetTemporaryLinkResult?, CallError<Files.GetTemporaryLinkError>?) -> Void) {
        
        guard let path = entry.pathLower else { return }
        
        let client = DropboxClientsManager.authorizedClient
        client?.files
            .getTemporaryLink(path: path)
            .response(queue: DispatchQueue.main, completionHandler: {
                completion($0, $1)
            })
    }
}
