//
//  VideoViewerViewModelTests.swift
//  dropbox-clientTests
//
//  Created by Anton Chuev on 06.09.2023.
//

import Foundation

import XCTest
import SwiftyDropbox
@testable import dropbox_client

final class VideoViewerViewModelTests: XCTestCase {
    
    var vm: VideoViewerViewModel!
    var entry: FileMetadata!
    var contentLinkService: ContentLinkServiceMock!
    var videoDownloadService: VideoDownloadServiceMock!
    var videoCache: VideoCacheMock!
    
    override func setUp() {
        contentLinkService = ContentLinkServiceMock()
        videoDownloadService = VideoDownloadServiceMock()
        videoCache = VideoCacheMock()
        
        entry = Files.FileMetadata.videoStub().toFileMetadata()
        
        vm = VideoViewerViewModel(entry: entry,
                                  contentLinkService: contentLinkService,
                                  videoDownloadService: videoDownloadService,
                                  videoCache: videoCache)
    }
    
    func test_entry_info_value_should_be_not_nil() {
        XCTAssertNil(vm.entryInfo.value)
        
        vm.viewDidLoad()
        
        XCTAssertNotNil(vm.entryInfo.value)
    }
    
    func test_get_content_link_should_be_called() {
        XCTAssertEqual(contentLinkService.getContentLinkGotCalledWith, (""))
        
        vm.fetchData()
        
        XCTAssertEqual(contentLinkService.getContentLinkGotCalledWith, (entry.id))
    }
    
    func test_get_content_link_should_succeed() {
        XCTAssertNil(entry.contentLink)
        
        vm.fetchData()
        contentLinkService.getContentLinkSuccess()
        
        XCTAssertNotNil(entry.contentLink)
        
    }
    
    func test_get_content_link_should_fail() {
        XCTAssertNil(vm.errorMessage.value)
        
        vm.fetchData()
        contentLinkService.getContentLinkFail(error: nil)
        
        XCTAssertNotNil(vm.errorMessage)
        
    }
    
    func test_download_video_should_be_called() {
        XCTAssertEqual(videoDownloadService.downloadVideoGotCalled, false)
        
        vm.fetchData()
        contentLinkService.getContentLinkSuccess()
        
        XCTAssertEqual(videoDownloadService.downloadVideoGotCalled, true)
    }
    
    func test_download_video_should_succeed() {
        XCTAssertNil(vm.playerItem.value)
        
        vm.fetchData()
        contentLinkService.getContentLinkSuccess()
        
        videoDownloadService.downloadVideoSuccess()
        
        XCTAssertNotNil(vm.playerItem.value)
    }
    
}
