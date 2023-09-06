//
//  ImageViewerViewModelTests.swift
//  dropbox-clientTests
//
//  Created by Anton Chuev on 06.09.2023.
//

import XCTest
import SwiftyDropbox
@testable import dropbox_client

final class ImageViewerViewModelTests: XCTestCase {
    
    var vm: ImageViewerViewModel!
    var entry: FileMetadata!
    var contentLinkService: ContentLinkServiceMock!
    var imageDataDownloadService: ImageDataDownloadServiceMock!
    var imageCache: ImageCacheByURLMock!
    
    override func setUp() {
        contentLinkService = ContentLinkServiceMock()
        imageDataDownloadService = ImageDataDownloadServiceMock()
        imageCache = ImageCacheByURLMock()
        
        entry = Files.FileMetadata.photoStub().toFileMetadata()
        
        vm = ImageViewerViewModel(entry: entry,
                                  contentLinkService: contentLinkService,
                                  imageDataDownloadService: imageDataDownloadService,
                                  imageCache: imageCache)
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
    
    func test_download_image_data_should_be_called() {
        XCTAssertEqual(imageDataDownloadService.downloadImageDataGotCalled, false)
        
        vm.fetchData()
        contentLinkService.getContentLinkSuccess()
        
        XCTAssertEqual(imageDataDownloadService.downloadImageDataGotCalled, true)
    }
    
    func test_download_image_should_succeed() {
        XCTAssertNil(vm.imageData.value)
        
        vm.fetchData()
        contentLinkService.getContentLinkSuccess()
        
        imageDataDownloadService.imageDataDownloadSuccess()
        
        XCTAssertNotNil(vm.imageData.value)
    }
    
    func test_download_image_should_fail() {
        XCTAssertNil(vm.errorMessage.value)
        XCTAssertNil(vm.imageData.value)
        
        vm.fetchData()
        contentLinkService.getContentLinkSuccess()
        
        imageDataDownloadService.imageDataDownloadFail(error: nil)
        
        XCTAssertNil(vm.imageData.value)
        XCTAssertNotNil(vm.errorMessage.value)
    }
    
}
