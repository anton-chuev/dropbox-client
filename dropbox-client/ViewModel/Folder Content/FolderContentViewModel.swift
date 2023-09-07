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
    private(set) var didSignOut = Observable<Bool>(false)
    private(set) var firstPageIsLoading = Observable<Bool>(false)
    private(set) var deletedEntryIndex = Observable<Int?>(nil)
    
    // MARK: - Readonly properties
    private(set) var hasMore = true
    private(set) var thumbnailCache: ImageCacheByIDType
    
    // MARK: - Private properties
    private var entries = [Metadata]()
    private var fetchService: FolderContentService
    private var deleteEntryService: DeleteEntryService
    private var signOutService: SignOutService
    private var currentPath = ""
    private var isFetchingInProgress = false
    private let pageLimit: UInt32 = 20
    private var currentPage = 0
    private var cursor: String?
    private var viewIsPopulated = false
    
    init(fetchService: FolderContentService,
         deleteEntryService: DeleteEntryService,
         signOutService: SignOutService,
         thumbnailsCache: ImageCacheByIDType) {
        self.fetchService = fetchService
        self.deleteEntryService = deleteEntryService
        self.signOutService = signOutService
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
    
    func deleteEntry(at index: Int) {
        let entry = entry(at: index)
        guard let path = entry.pathLower else {
            return
        }
        deleteEntryService.delete(at: path) { [weak self] result, error in
            if let _ = error {
                self?.errorMessage.value = "Fail deleting entry"
            } else {
                self?.entries.remove(at: index)
                self?.deletedEntryIndex.value = index
            }
        }
    }
    
    func signOut() {
        thumbnailCache.removeAllImages()
        signOutService.signOut()
        didSignOut.value = true
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
