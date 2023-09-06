//
//  ImageViewerViewController.swift
//  dropbox-client
//
//  Created by Anton Chuev on 05.09.2023.
//

import UIKit

final class ImageViewerViewController: UIViewController {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var viewModel: ImageViewerViewModel!
    private var coordinator: Coordinator!
    private var mediaInfo: String?
    
    static func create(with viewModel: ImageViewerViewModel, coordinator: Coordinator) -> ImageViewerViewController {
        let vc = ImageViewerViewController()
        vc.viewModel = viewModel
        vc.coordinator = coordinator
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = mediaInfoBarButton()
        
        bind(to: viewModel)
        viewModel.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.fetchData()
    }
    
    override func didReceiveMemoryWarning() {
        viewModel.cleanImageCache()
    }
    
    private func bind(to viewModel: ImageViewerViewModel) {
            
        viewModel.isLoading.bind { [weak self] isLoading in
            DispatchQueue.main.async {
                isLoading ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
            }
        }
        
        viewModel.entryInfo.bind { [weak self] info in
            DispatchQueue.main.async {
                self?.mediaInfo = info
                self?.setMediaInfoButtonEnable(info != nil)
            }
        }
        
        viewModel.image.bind { [weak self] image in
            guard let image = image else { return }
            DispatchQueue.main.async {
                self?.image.image = image
            }
        }
        
        viewModel.errorMessage.bind { [weak self] errorMessage in
            guard let message = errorMessage else { return }
            DispatchQueue.main.async {
                self?.coordinator?.showAlert(title: "Error", message: message)
            }
        }
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
