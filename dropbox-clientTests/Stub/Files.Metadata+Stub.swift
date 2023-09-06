//
//  Files.Metadata+Stub.swift
//  dropbox-clientTests
//
//  Created by Anton Chuev on 06.09.2023.
//

import SwiftyDropbox
import Foundation

extension Files.FileMetadata {
    static func photoStub() -> Files.FileMetadata {
        Files.FileMetadata(name: "Photo1",
                           id: "111111111",
                           clientModified: Date(),
                           serverModified: Date(),
                           rev: "111111111",
                           size: 1,
                           pathLower: "/photo1",
                           pathDisplay: "/Photo1",
                           mediaInfo: Files.MediaInfo.metadata(Files.PhotoMetadata.stub()),
                           isDownloadable: true,
                           contentHash: "e51765f21dc5768d3e613247923eafc4853762213988deec62242f91f0fae402")
    }
    
    static func videoStub() -> Files.FileMetadata {
        Files.FileMetadata(name: "Video2",
                           id: "222222222",
                           clientModified: Date(),
                           serverModified: Date(),
                           rev: "222222222",
                           size: 2,
                           pathLower: "/video2",
                           pathDisplay: "/Video2",
                           mediaInfo: Files.MediaInfo.metadata(Files.VideoMetadata.stub()),
                           isDownloadable: true,
                           contentHash: "e51765f21dc5768d3e613247923eafc4853762213988deec62242f91f0fae403")
    }
}

extension Files.FolderMetadata {
    static func stub() -> Files.FolderMetadata {
        Files.FolderMetadata(name: "Documents", id: "333333333")
    }
}

extension Files.VideoMetadata {
    static func stub() -> Files.VideoMetadata {
        return Files.VideoMetadata(dimensions: Files.Dimensions(height: 10, width: 10), timeTaken: Date(), duration: 1000*10) as! Self
    }
}

extension Files.PhotoMetadata {
    static func stub() -> Files.PhotoMetadata {
        return Files.PhotoMetadata(dimensions: Files.Dimensions(height: 10, width: 10), timeTaken: Date()) as! Self
    }
}

                        
                            
