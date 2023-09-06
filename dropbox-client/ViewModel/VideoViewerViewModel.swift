//
//  VideoViewerViewModel.swift
//  dropbox-client
//
//  Created by Anton Chuev on 05.09.2023.
//

import AVFoundation

final class VideoViewerViewModel: NSObject {
    //MARK: - Observables
    private(set) var errorMessage = Observable<String?>(nil)
    private(set) var isLoading = Observable<Bool>(false)
    private(set) var entryInfo = Observable<String?>(nil)
    private(set) var playerItem = Observable<AVPlayerItem?>(nil)
    private(set) var isReadyToPlayVideo = Observable<Bool>(false)
    
    // MARK: - Private properties
    private var entry: FileMetadata
    private var contentLinkService: ContentLinkService
    private var videoDownloadService: VideoDownloadService
    private var videoCache: VideoCacheType
    
    // For KVO
    private var playerItemContext = 0
    
    init(entry: FileMetadata,
         contentLinkService: ContentLinkService,
         videoDownloadService: VideoDownloadService,
         videoCache: VideoCacheType) {
        self.entry = entry
        self.contentLinkService = contentLinkService
        self.videoDownloadService = videoDownloadService
        self.videoCache = videoCache
    }
    
    // MARK: - Intentions
    func viewDidLoad() {
        entryInfo.value = EntryPrettyInfoStringComposer.prettyString(from: entry)
    }
    
    func fetchData() {
        getContentLink()
    }
    
    func cleanVideoCache() {
        videoCache.removeAllVideos()
    }
    
    // MARK: - Private
    private func getContentLink() {
        
        let cacheURL = VideoCacheURLComposer.cacheURL(for: entry, cache: videoCache)
        if
            let alreadyCachedURL = videoCache.video(for: cacheURL)
        {
            print("Get video from cache for \(self.entry.name)")
            setupPlayer(from: alreadyCachedURL)
            return
        }
        
        isLoading.value = true
        
        contentLinkService.getContentLink(of: entry) { [weak self] result, error in
            if let error = error {
                // TODO: Add proper error handling
                self?.isLoading.value = false
                self?.errorMessage.value = error.description
            } else if let result = result, let strongSelf = self {
                guard let remoteURL = URL(string: result.link) else {
                    strongSelf.errorMessage.value = "Bad url. Can't play video"
                    return
                }
                // Update entry using reference semantic
                strongSelf.entry.contentLink = result.link
                let cachedURL = VideoCacheURLComposer.cacheURL(for: strongSelf.entry, cache: strongSelf.videoCache)
                
                if let alreadyCachedURL = strongSelf.videoCache.video(for: cachedURL) {
                    strongSelf.setupPlayer(from: alreadyCachedURL)
                } else {
                    strongSelf.dowloadVideo(for: strongSelf.entry, from: remoteURL)
                    strongSelf.setupPlayer(from: remoteURL)
                }
                
            } else {
                self?.errorMessage.value = "Bad URL. Can't play video"
            }
        }
    }
    
    private func setupPlayer(from url: URL) {
        let asset = AVAsset(url: url)
        playerItem.value = AVPlayerItem(asset: asset)
        playerItem.value?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: &self.playerItemContext)
    }
    
    private func dowloadVideo(for entry: FileMetadata, from url: URL) {
        // Let service finish file downloading even if screen was closed
        videoDownloadService.downloadVideo(from: url) { tempFileURL in
            if let tempFileURL = tempFileURL {
                let localURL = VideoCacheURLComposer.cacheURL(for: self.entry, cache: self.videoCache)
                self.videoCache.insertVideo(to: localURL, from: tempFileURL)
            }
        }
    }
    
    // MARK: - KVO, AVPlayerItem.Status observation
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // Only handle observations for the playerItemContext
            guard context == &playerItemContext else {
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
                return
            }
        
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            // TODO: React on all statuses
            switch status {
            case .readyToPlay:
                print(".readyToPlay")
                isReadyToPlayVideo.value = true
                isLoading.value = false
            case .failed: print(".failed")
            case .unknown: print(".unknown")
            @unknown default: print("@unknown default")
            }
        }
    }
    
    deinit {
        playerItem.value?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
    }
}

fileprivate struct VideoCacheURLComposer {
    static func cacheURL(for entry: FileMetadata, cache: VideoCacheType) -> URL {
        var filename = entry.name
        if let hash = entry.contentHash {
            let nameComponents = entry.name.components(separatedBy: ".")
            filename = (nameComponents.first ?? "") + "_" + hash + "." + nameComponents.last!
        }
        let url = cache.videoCacheDirectory.appendingPathComponent(filename)
        print("Local URL for caching \(entry.name) is \(url.path)")
        return url
    }
}
