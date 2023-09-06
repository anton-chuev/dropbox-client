//
//  File.Metadata+Mapping.swift
//  dropbox-client
//
//  Created by Anton Chuev on 01.09.2023.
//

import SwiftyDropbox

extension Files.Metadata {
    func toMetadata() -> Metadata {
        if let folder = self as? Files.FolderMetadata {
            return folder.toFolderMetadata()
        } else if let file = self as? Files.FileMetadata {
            return file.toFileMetadata()
        } else if let deleted = self as? Files.DeletedMetadata {
            return deleted.toDeletedMetadata()
        } else {
            fatalError()
        }
    }
}

extension Files.FileMetadata {
    func toFileMetadata() -> FileMetadata {
        
        let result = FileMetadata(name: name,
                            pathLower: pathLower,
                            previewUrl: previewUrl,
                            id: id,
                            clientModified: clientModified,
                            serverModified: serverModified,
                            rev: rev,
                            size: size,
                            contentHash: contentHash)
        result.mediaMetadata = mediaInfo?.toMediaMetadata()
        
        return result
    }
}

extension Files.FolderMetadata {
    func toFolderMetadata() -> FolderMetadata {
        return FolderMetadata(name: name,
                              pathLower: pathLower,
                              previewUrl: previewUrl,
                              id: id)
    }
}

extension Files.DeletedMetadata {
    func toDeletedMetadata() -> DeletedMetadata {
        return DeletedMetadata(name: name,
                               pathLower: pathLower,
                               previewUrl: previewUrl)
    }
}

extension Files.MediaInfo {
    func toMediaMetadata() -> MediaMetadata? {
        var mediaMetadata: MediaMetadata?
        switch self {
        case .pending:
            print("Pending")
        case .metadata(let metadata):
            switch metadata {
            case let videoMetadata as Files.VideoMetadata:
                var dimensions: Dimensions?
                if let dims = videoMetadata.dimensions {
                    dimensions = Dimensions(width: dims.width, height: dims.height)
                }
                mediaMetadata = VideoMetadata(duration: videoMetadata.duration, timestamp: videoMetadata.timeTaken, dimensions: dimensions)
                
            case let photoMetadata as Files.PhotoMetadata:
                var dimensions: Dimensions?
                if let dims = photoMetadata.dimensions {
                    dimensions = Dimensions(width: dims.width, height: dims.height)
                }
                var coordinates: GpsCoordinates?
                if let coords = photoMetadata.location {
                    coordinates = GpsCoordinates(latitude: coords.latitude, longitude: coords.longitude)
                }
                mediaMetadata = PhotoMetadata(location: coordinates, dimensions: dimensions, timestamp: photoMetadata.timeTaken)
            default: break
            }
        }
        
        return mediaMetadata
    }
}
