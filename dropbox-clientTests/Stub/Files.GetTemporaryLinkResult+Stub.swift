//
//  Files.GetTemporaryLinkResult+Stub.swift
//  dropbox-clientTests
//
//  Created by Anton Chuev on 06.09.2023.
//

import SwiftyDropbox

extension Files.GetTemporaryLinkResult {
    static func stub() -> Files.GetTemporaryLinkResult {
        Files.GetTemporaryLinkResult(metadata: Files.FileMetadata.photoStub(), link: "https://stub.com/downloads/image")
    }
}
