//
//  MediaMetadata.swift
//  dropbox-client
//
//  Created by Anton Chuev on 01.09.2023.
//

import Foundation

protocol MediaMetadata {
    var dimensions: Dimensions? { get set }
    var timestamp: Date? { get set }
}

struct VideoMetadata: MediaMetadata {
    var duration: UInt64?
    var timestamp: Date?
    var dimensions: Dimensions?
}

struct PhotoMetadata: MediaMetadata {
    var location: GpsCoordinates?
    var dimensions: Dimensions?
    var timestamp: Date?
}

struct Dimensions {
    var width: UInt64
    var height: UInt64
}

struct GpsCoordinates {
    let latitude: Double
    let longitude: Double
}
