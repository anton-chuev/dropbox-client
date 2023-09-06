//
//  Files.ListFolderResultStub.swift
//  dropbox-clientTests
//
//  Created by Anton Chuev on 06.09.2023.
//

import SwiftyDropbox

extension Files.ListFolderResult {
    static func stub() -> Files.ListFolderResult {
        let entries = [Files.FolderMetadata.stub(), Files.FileMetadata.photoStub(), Files.FileMetadata.videoStub()]
        return Files.ListFolderResult(entries: entries, cursor: "stub", hasMore: true)
    }
}

