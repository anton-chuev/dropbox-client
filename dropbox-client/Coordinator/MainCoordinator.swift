//
//  MainCoordinator.swift
//  dropbox-client
//
//  Created by Anton Chuev on 31.08.2023.
//

import UIKit
import SwiftyDropbox
import AVFoundation
import AVKit

protocol ShowingEntryDetails: AnyObject {
    func entryViewer(_ metadata: FileMetadata)
}

protocol PopingToLogin: AnyObject {
    func popToLogin()
}

class MainCoordinator: Coordinator, ShowingEntryDetails, PopingToLogin {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    private var imageCacheByID: ImageCacheByIDType = ImageCache()
    private var imageCacheByURL: ImageCacheByURLType = ImageCache()
    private var videoCache: VideoCacheType = VideoCache()

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        if AuthorizationStatus.isAutorized {
            showRootFolderContent()
        } else {
            let viewModel = LoginViewModel(authService: DefaultAuthService())
            let vc = LoginViewController.create(with: viewModel)
            navigationController.pushViewController(vc, animated: false)
        }
    }
    
    func showRootFolderContent() {
        let viewModel =
        FolderContentViewModel(fetchService: DefaultFolderContentService(),
                               logoutService: DefaultLogoutService(),
                               thumbnailsCache: imageCacheByID)
        let vc = FolderContentViewController.create(with: viewModel, coordinator: self)
        navigationController.pushViewController(vc, animated: false)
    }
    
    func entryViewer(_ metadata: FileMetadata) {
        guard let mediaMetadata = metadata.mediaMetadata else { return }
        if mediaMetadata is VideoMetadata {
            let viewModel = VideoViewerViewModel(entry: metadata,
                                                 contentLinkService: DefaultContentLinkService(),
                                                 videoDownloadService: DefaultVideoDownloadService(),
                                                 videoCache: videoCache)
            let vc = VideoViewerViewController.create(with: viewModel, coordinator: self)
            navigationController.pushViewController(vc, animated: true)
        } else { // PhotoMetadata
            let viewModel =
            ImageViewerViewModel(entry: metadata,
                                 contentLinkService: DefaultContentLinkService(),
                                 imageDataDownloadService: DefaultImageDataService(),
                                 imageCache: imageCacheByURL)
            let vc = ImageViewerViewController.create(with: viewModel, coordinator: self)
            navigationController.pushViewController(vc, animated: true)
        }
    }
    
    func popToLogin() {
        let root = navigationController.viewControllers.first
        if root is LoginViewController {
            navigationController.popToRootViewController(animated: true)
        } else {
            let viewModel = LoginViewModel(authService: DefaultAuthService())
            let vc = LoginViewController.create(with: viewModel)
            navigationController.setViewControllers([vc], animated: true)
        }
    }
}
