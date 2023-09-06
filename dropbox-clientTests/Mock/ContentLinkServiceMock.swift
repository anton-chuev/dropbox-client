//
//  ContentLinkSerivceMock.swift
//  dropbox-clientTests
//
//  Created by Anton Chuev on 06.09.2023.
//

@testable import dropbox_client
import SwiftyDropbox
import Foundation

final class ContentLinkServiceMock {
    var getContentLinkGotCalledWith = (String())
    var completeClosure: ((Files.GetTemporaryLinkResult?, CallError<Files.GetTemporaryLinkError>?) -> Void)!
    
    func getContentLinkSuccess() {
        completeClosure(Files.GetTemporaryLinkResult.stub(), nil)
    }
        
    func getContentLinkFail(error: Error?) {
        completeClosure(nil, CallError.clientError(nil))
    }
}

extension ContentLinkServiceMock: ContentLinkService {
    func getContentLink(of entry: FileMetadata, completion: @escaping (Files.GetTemporaryLinkResult?, CallError<Files.GetTemporaryLinkError>?) -> Void) {
        completeClosure = completion
        getContentLinkGotCalledWith = (entry.id)
    }
}
