//
//  Files.DeleteResult+Stub.swift
//  dropbox-clientTests
//
//  Created by Anton Chuev on 07.09.2023.
//

import SwiftyDropbox

extension Files.DeleteResult {
    static func stub() -> Files.DeleteResult {
        Files.DeleteResult(metadata: Files.FileMetadata.photoStub())
    }
}

