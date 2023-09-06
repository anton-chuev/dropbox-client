//
//  Metadata.swift
//  dropbox-client
//
//  Created by Anton Chuev on 03.09.2023.
//

import Foundation
import SwiftyDropbox

class Metadata {
    // MARK: Properties from Files.Metadata
    /// The last component of the path (including extension). This never contains a slash.
    let name: String
    /// The lowercased full path in the user's Dropbox. This always starts with a slash. This field will be null if
    /// the file or folder is not mounted.
    public let pathLower: String?
    /// The preview URL of the file.
    let previewUrl: String?
    
    var isFolder: Bool { self is FolderMetadata }
    
    init(name: String, pathLower: String?, previewUrl: String?) {
        self.name = name
        self.pathLower = pathLower
        self.previewUrl = previewUrl
    }
}

class FileMetadata: Metadata {
    // MARK: Properties from Files.FileMetadata
    let id: String
    let clientModified: Date
    /// The last time the file was modified on Dropbox.
    let serverModified: Date
    /// A unique identifier for the current revision of a file. This field is the same rev as elsewhere in the API
    /// and can be used to detect changes and avoid conflicts.
    let rev: String
    /// The file size in bytes.
    let size: UInt64
    /// A hash of the file content. This field can be used to verify data integrity. For more information see our
    /// Content hash https://www.dropbox.com/developers/reference/content-hash page.
    let contentHash: String?
    
    /// Additional information if the file is a photo or video
    var mediaMetadata: MediaMetadata?
    
    var contentLink: String?
    
    init(name: String, pathLower: String?, previewUrl: String?, id: String, clientModified: Date, serverModified: Date, rev: String, size: UInt64, contentHash: String?, mediaMetadata: MediaMetadata? = nil, contentLink: String? = nil) {
        self.id = id
        self.clientModified = clientModified
        self.serverModified = serverModified
        self.rev = rev
        self.size = size
        self.contentHash = contentHash
        self.mediaMetadata = mediaMetadata
        self.contentLink = contentLink
        
        super.init(name: name, pathLower: pathLower, previewUrl: previewUrl)
    }
}

class FolderMetadata: Metadata {
    let id: String
    
    init(name: String, pathLower: String?, previewUrl: String?, id: String) {
        self.id = id
        super.init(name: name, pathLower: pathLower, previewUrl: previewUrl)
    }
}

class DeletedMetadata: Metadata {}

