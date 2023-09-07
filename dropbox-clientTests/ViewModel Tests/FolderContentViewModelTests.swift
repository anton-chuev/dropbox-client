//
//  FolderContentViewModelTests.swift
//  dropbox-clientTests
//
//  Created by Anton Chuev on 06.09.2023.
//

import XCTest
@testable import dropbox_client

final class FolderContentViewModelTests: XCTestCase {
    
    var vm: FolderContentViewModel!
    var fetchService: FolderContentServiceMock!
    var signOutService: SignOutServiceMock!
    var thumbnailsCache: ImageCacheByIDMock!
    
    override func setUp() {
        fetchService = FolderContentServiceMock()
        signOutService = SignOutServiceMock()
        thumbnailsCache = ImageCacheByIDMock()
        vm = FolderContentViewModel(fetchService: fetchService, signOutService: signOutService, thumbnailsCache: thumbnailsCache)
    }
    
    func test_fetch_folder_content_should_succeed() {
        XCTAssertEqual(vm.newEntries.value.count, 0)
        vm.fetchContent()
        fetchService.fetchContentSuccess()
        XCTAssertEqual(vm.newEntries.value.count, 3)
    }
    
    func test_fetch_folder_content_should_fail() {
        XCTAssertNil(vm.errorMessage.value)
        vm.fetchContent()
        fetchService.fetchContentFail(error: nil)
        XCTAssertNotNil(vm.errorMessage.value)
    }
    
    func test_continue_fetching_should_succeed() {
        XCTAssertEqual(vm.newEntries.value.count, 0)
        vm.fetchContent()
        fetchService.fetchContentSuccess()
        XCTAssertEqual(vm.newEntries.value.count, 3)
        
        XCTAssertEqual(fetchService.continueFetchingGotCalled, false)
        vm.fetchContent()
        fetchService.continueFetchingContentSuccess()
        let nextPageEntries = (3...5).map { vm.entry(at: $0) }
        XCTAssertEqual(fetchService.continueFetchingGotCalled, true)
        XCTAssertEqual(nextPageEntries.count, 3)
    }
    
    func test_continue_fetching_should_fail() {
        XCTAssertEqual(vm.newEntries.value.count, 0)
        vm.fetchContent()
        fetchService.fetchContentSuccess()
        XCTAssertEqual(vm.newEntries.value.count, 3)
        
        XCTAssertNil(vm.errorMessage.value)
        vm.fetchContent()
        fetchService.continueFetchingContentFail(error: nil)
        XCTAssertNotNil(vm.errorMessage.value)
    }
    
    func test_signout_should_be_called() {
        XCTAssertEqual(signOutService.signOutGotCalled, false)
        
        vm.signOut()
        
        XCTAssertEqual(signOutService.signOutGotCalled, true)
    }
    
}
