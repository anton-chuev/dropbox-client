//
//  FolderContentViewModel.swift
//  dropbox-client
//
//  Created by Anton Chuev on 31.08.2023.
//

import UIKit
import SwiftyDropbox

final class FolderContentViewModel {
    // MARK: - Observables
    private(set) var newEntries = Observable<[Metadata]>([])
    private(set) var errorMessage = Observable<String?>(nil)
    private(set) var didLogOut = Observable<Bool>(false)
    private(set) var firstPageIsLoading = Observable<Bool>(false)
    
    // MARK: - Readonly properties
    private(set) var hasMore = true
    private(set) var thumbnailCache: ImageCacheByIDType
    
    // MARK: - Private properties
    private var entries = [Metadata]()
    private var fetchService: FolderContentService
    private var logoutService: LogoutService
    private var currentPath = ""
    private var isFetchingInProgress = false
    private let pageLimit: UInt32 = 20
    private var currentPage = 0
    private var cursor: String?
    private var viewIsPopulated = false
    
    init(fetchService: FolderContentService,
         logoutService: LogoutService,
         thumbnailsCache: ImageCacheByIDType) {
        self.fetchService = fetchService
        self.logoutService = logoutService
        self.thumbnailCache = thumbnailsCache
    }
    
    // MARK: - Intentions
    
    func fetchContent() {
        
        guard !isFetchingInProgress, hasMore else { return }
        
        isFetchingInProgress = true
        
        if entries.count == 0 && !viewIsPopulated {
            firstPageIsLoading.value = true
        }
        if let cursor = cursor {
            fetchService.continueFetchingContent(from: cursor) { [weak self] response, error in
                if let error = error {
                    // TODO: Add proper error handling
                    self?.fetchFailed(error)
                } else if let response = response {
                    self?.fetchCompleted(response)
                }
                self?.isFetchingInProgress = false
            }
        } else {
            fetchService.fetchContent(at: currentPath, limit: pageLimit) { [weak self] response, error in
                self?.firstPageIsLoading.value = false
                if let error = error {
                    // TODO: Add proper error handling
                    self?.fetchFailed(error)
                } else if let response = response {
                    self?.fetchCompleted(response)
                }
                self?.isFetchingInProgress = false
            }
        }
    }
    
    func logout() {
        thumbnailCache.removeAllImages()
        logoutService.logout()
        didLogOut.value = true
    }
    
    // MARK: - Helpers
    
    var currentCount: Int {
        return entries.count
    }
    
    func entry(at index: Int) -> Metadata {
        return entries[index]
    }
    
    func calculateIndexPathsToReload(from newEntries: [Metadata]) -> [IndexPath] {
        let isLoadingCellRow = entries.count - newEntries.count
        return [IndexPath(row: isLoadingCellRow, section: 0)]
    }
    
    func calculateIndexPathsToAdd(from newEntries: [Metadata]) -> [IndexPath]? {
        if currentPage <= 1 { return .none }
        let isLoadingCellGap = hasMore ? 1 : 0
        let startIndex = entries.count - newEntries.count + 1
        let endIndex = entries.count + isLoadingCellGap
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
    
    func resetCursor() {
        cursor = nil
        currentPage = 0
        hasMore = true
        entries.removeAll()
        newEntries.value.removeAll()
    }
    
    func clearImageCache() {
        thumbnailCache.removeAllImages()
    }
    
    // MARK: - Private
    
    private func fetchCompleted(_ response: Files.ListFolderResult) {
        hasMore = response.hasMore
        currentPage += 1
        cursor = response.cursor
        let newEntries = response.entries.map { $0.toMetadata() }
        viewIsPopulated = !newEntries.isEmpty
        entries.append(contentsOf: newEntries)
        self.newEntries.value = newEntries
    }
    
    private func fetchFailed<T>(_ error: CallError<T>) {
        errorMessage.value = "Failed fetching content with error: " + error.description
    }
}
