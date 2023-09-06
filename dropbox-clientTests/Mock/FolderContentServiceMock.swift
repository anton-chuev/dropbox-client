//
//  FolderContentServiceMock.swift
//  dropbox-clientTests
//
//  Created by Anton Chuev on 06.09.2023.
//

import Foundation
import SwiftyDropbox
@testable import dropbox_client

final class FolderContentServiceMock {
    var fetchCompletion: ((Files.ListFolderResult?, CallError<Files.ListFolderError>?) -> Void)!
    var continueFetchingCompletion: ((Files.ListFolderResult?, CallError<Files.ListFolderContinueError>?) -> Void)!
    var continueFetchingGotCalled = false
    
    func fetchContentSuccess() {
        fetchCompletion(Files.ListFolderResult.stub(), nil)
    }
        
    func fetchContentFail(error: Error?) {
        fetchCompletion(nil, CallError.clientError(nil))
    }
    
    func continueFetchingContentSuccess() {
        fetchCompletion(Files.ListFolderResult.stub(), nil)
    }
        
    func continueFetchingContentFail(error: Error?) {
        fetchCompletion(nil, CallError.clientError(nil))
    }
}

extension FolderContentServiceMock: FolderContentService {
    func fetchContent(at path: String, limit: UInt32?, completion: @escaping (Files.ListFolderResult?, CallError<Files.ListFolderError>?) -> Void) {
        fetchCompletion = completion
    }
    
    func continueFetchingContent(from cursor: String, completion: @escaping (Files.ListFolderResult?, CallError<Files.ListFolderContinueError>?) -> Void) {
        continueFetchingGotCalled = true
        continueFetchingCompletion = completion
    }
}
