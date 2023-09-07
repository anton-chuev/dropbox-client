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
    var deleteEntryService: DeleteEntryServiceMock!
    var signOutService: SignOutServiceMock!
    var thumbnailsCache: ImageCacheByIDMock!
    
    override func setUp() {
        fetchService = FolderContentServiceMock()
        deleteEntryService = DeleteEntryServiceMock()
        signOutService = SignOutServiceMock()
        thumbnailsCache = ImageCacheByIDMock()
        vm = FolderContentViewModel(fetchService: fetchService,
                                    deleteEntryService: deleteEntryService,
                                    signOutService: signOutService,
                                    thumbnailsCache: thumbnailsCache)
    }
    
    func test_fetch_folder_content_should_succeed() {
        XCTAssertEqual(vm.currentCount, 0)
        vm.fetchContent()
        fetchService.fetchContentSuccess()
        XCTAssertEqual(vm.currentCount, 3)
    }
    
    func test_fetch_folder_content_should_fail() {
        XCTAssertNil(vm.errorMessage.value)
        vm.fetchContent()
        fetchService.fetchContentFail(error: nil)
        XCTAssertNotNil(vm.errorMessage.value)
    }
    
    func test_continue_fetching_should_succeed() {
        XCTAssertEqual(vm.currentCount, 0)
        vm.fetchContent()
        fetchService.fetchContentSuccess()
        XCTAssertEqual(vm.currentCount, 3)
        
        XCTAssertEqual(fetchService.continueFetchingGotCalled, false)
        vm.fetchContent()
        fetchService.continueFetchingContentSuccess()
        let nextPageEntries = (3...5).map { vm.entry(at: $0) }
        XCTAssertEqual(fetchService.continueFetchingGotCalled, true)
        XCTAssertEqual(nextPageEntries.count, 3)
    }
    
    func test_continue_fetching_should_fail() {
        XCTAssertEqual(vm.currentCount, 0)
        vm.fetchContent()
        fetchService.fetchContentSuccess()
        XCTAssertEqual(vm.currentCount, 3)
        
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
    
    func test_entry_at_should_return_entry() {
        XCTAssertNil(vm.deletedEntryIndex.value)
        
        vm.fetchContent()
        fetchService.fetchContentSuccess()
        
        XCTAssertNotNil(vm.entry(at: 1))
    }
    
    func test_delete_entry_should_be_called() {
        vm.fetchContent()
        fetchService.fetchContentSuccess()
        let entry = vm.entry(at: 1)
        vm.deleteEntry(at: 1)
        deleteEntryService.deleteEntrySuccess()
        XCTAssertEqual(deleteEntryService.deleteEntryGotCalledWith, (entry.pathLower!))
    }
    
    func test_delete_entry_should_succeed() {
        XCTAssertNil(vm.deletedEntryIndex.value)
        vm.fetchContent()
        fetchService.fetchContentSuccess()
        
        XCTAssertEqual(vm.currentCount, 3)
        vm.deleteEntry(at: 1)
        deleteEntryService.deleteEntrySuccess()
        XCTAssertEqual(vm.currentCount, 2)
    }
}
