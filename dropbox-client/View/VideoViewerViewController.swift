//
//  VideoViewerViewController.swift
//  dropbox-client
//
//  Created by Anton Chuev on 05.09.2023.
//

import UIKit
import AVKit

final class VideoViewerViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var playerContainer: UIView!
    
    private var viewModel: VideoViewerViewModel!
    private var coordinator: Coordinator!
    private var mediaInfo: String?
    
    static func create(with viewModel:VideoViewerViewModel, coordinator: Coordinator) -> VideoViewerViewController {
        let vc = VideoViewerViewController()
        vc.viewModel = viewModel
        vc.coordinator = coordinator
        return vc
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = mediaInfoBarButton()
        playerContainer.isHidden = true
        
        bind(to: viewModel)
        viewModel.viewDidLoad()
        viewModel.fetchData()
    }
    
    override func didReceiveMemoryWarning() {
        viewModel.cleanVideoCache()
    }
    
    // MARK: - Private
    private func bind(to: VideoViewerViewModel) {
        
        viewModel.entryInfo.bind { [weak self] info in
            DispatchQueue.main.async {
                self?.mediaInfo = info
                self?.setMediaInfoButtonEnable(info != nil)
            }
        }
        
        viewModel.isLoading.bind { [weak self] isLoading in
            DispatchQueue.main.async {
                isLoading ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
            }
        }
        
        viewModel.errorMessage.bind { [weak self] errorMessage in
            guard let message = errorMessage else { return }
            DispatchQueue.main.async {
                self?.coordinator?.showAlert(title: "Error", message: message)
            }
        }
        
        viewModel.playerItem.bind { [weak self] playerItem in
            guard let playerItem = playerItem else { return }
            DispatchQueue.main.async {
                self?.addPlayerController(playerItem: playerItem)
            }
        }
        
        viewModel.isReadyToPlayVideo.bind { [weak self] isReadyToPlay in
            guard isReadyToPlay else { return }
            DispatchQueue.main.async {
                self?.playerContainer.isHidden = false
            }
        }
    }
    
    private func addPlayerController(playerItem: AVPlayerItem) {
        let player = AVPlayer(playerItem: playerItem)
        player.rate = 1 //auto play
        let playerFrame = CGRect(x: 0, y: 0, width: playerContainer.frame.width, height: playerContainer.frame.height)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.view.frame = playerFrame
        
        addChild(playerViewController)
        playerContainer.addSubview(playerViewController.view)
        playerViewController.didMove(toParent: self)
    }

    @objc private func mediaInfoButtonTapped() {
        coordinator.showActionSheet(title: nil, message: mediaInfo)
    }
    
    private func mediaInfoBarButton() -> UIBarButtonItem {
        let mediaInfoButton = UIButton(type: .custom)
        mediaInfoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        mediaInfoButton.addTarget(self, action:#selector(mediaInfoButtonTapped), for: .touchUpInside)
        return UIBarButtonItem(customView: mediaInfoButton)
    }
    
    private func setMediaInfoButtonEnable(_ isEnabled: Bool) {
        navigationItem.rightBarButtonItem?.isEnabled = isEnabled
    }
}
