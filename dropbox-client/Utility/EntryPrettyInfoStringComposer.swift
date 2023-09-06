//
//  EntryPrettyInfoStringComposer.swift
//  dropbox-client
//
//  Created by Anton Chuev on 05.09.2023.
//

import Foundation

struct EntryPrettyInfoStringComposer {
    static func prettyString(from entry: Metadata) -> String {
        let fileMetadata = entry as! FileMetadata
        var info = fileMetadata.name
        guard let mediaMetadata = fileMetadata.mediaMetadata else {
            return info
        }
        
        if let timestamp = mediaMetadata.timestamp {
            let dateFormatter = dateFormatter
            info += "\nDate: " + dateFormatter.string(from: timestamp)
        }
        
        if let videoMetadata = mediaMetadata as? VideoMetadata {
            if
                let duration = videoMetadata.duration,
                let prettyDuration = durationFormatter.string(from: TimeInterval(duration/1000))
            {
                info += "\nDuration: " + prettyDuration
            }
        } else if let photoMetadata = mediaMetadata as? PhotoMetadata {
            if let location = photoMetadata.location {
                info += "\nLocation: \(location.latitude),\(location.longitude)"
            }
        }
        return info
    }
    
    static private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    static private let durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .full
        return formatter
    }()
}
