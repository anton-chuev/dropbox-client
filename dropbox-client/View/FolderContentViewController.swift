//
//  FolderContentViewController.swift
//  dropbox-client
//
//  Created by Anton Chuev on 31.08.2023.
//

import UIKit
import AVFoundation
import AVKit

final class FolderContentViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var viewModel: FolderContentViewModel!
    private weak var coordinator: (Coordinator & ShowingEntryDetails & PopingToLogin)?
    
    // MARK: - Fabric method
    static func create(with viewModel: FolderContentViewModel,
                       coordinator: (Coordinator & ShowingEntryDetails & PopingToLogin)) -> FolderContentViewController {
        let vc = FolderContentViewController()
        vc.viewModel = viewModel
        vc.coordinator = coordinator as? MainCoordinator
        return vc
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        title = "Files"
        
        navigationItem.rightBarButtonItem = logoutBarButton()
        navigationItem.setHidesBackButton(true, animated: false)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(EntryCell.nib, forCellReuseIdentifier: EntryCell.reusableIdentifier)
        tableView.isHidden = true
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadFirstPage), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        bind(to: viewModel)
        viewModel.fetchContent()
    }
    
    override func didReceiveMemoryWarning() {
        viewModel.clearImageCache()
    }
    
    // MARK: - Private
    private func bind(to viewModel: FolderContentViewModel) {
        
        viewModel.newEntries.bind { [weak self] newEntries in
            DispatchQueue.main.async {
                
                guard newEntries.count > 0 else {
                    self?.tableView.refreshControl?.endRefreshing()
                    return
                }
            
                guard let indexPathsToAdd = viewModel.calculateIndexPathsToAdd(from: newEntries) else {
                    self?.tableView.isHidden = false
                    self?.tableView.reloadData()
                    self?.tableView.refreshControl?.endRefreshing()
                    return
                }
                
                self?.tableView.beginUpdates()
                let indexPathsToReload = viewModel.calculateIndexPathsToReload(from: newEntries)
                self?.tableView.reloadRows(at: indexPathsToReload, with: .none)
                self?.tableView.insertRows(at: indexPathsToAdd, with: .none)
                self?.tableView.endUpdates()
            }
        }
        
        viewModel.errorMessage.bind { [weak self] errorMessage in
            if let message = errorMessage {
                DispatchQueue.main.async {
                    self?.coordinator?.showAlert(title: "Error", message: message)
                }
            }
        }
        
        viewModel.firstPageIsLoading.bind { [weak self] isLoading in
            DispatchQueue.main.async {
                if isLoading {
                    self?.activityIndicator.isHidden = false
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
            }
        }
        
        viewModel.didLogOut.bind { [weak self] loggedOut in
            if loggedOut { self?.coordinator?.popToLogin() }
        }
        
    }
    
    @objc private func loadFirstPage() {
        viewModel.resetCursor()
        viewModel.fetchContent()
    }
    
    @objc private func logoutTapped() {
        viewModel.logout()
    }
    
    private func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return viewModel.hasMore && indexPath.row >= viewModel.currentCount
    }
    
    private func logoutBarButton() -> UIBarButtonItem {
        let logOutButton = UIButton(type: .custom)
        logOutButton.setImage(UIImage(systemName: "rectangle.portrait.and.arrow.right"), for: .normal)
        logOutButton.addTarget(self, action:#selector(logoutTapped), for: .touchUpInside)
        return UIBarButtonItem(customView: logOutButton)
    }
}

extension FolderContentViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let isLoadingCellGap = viewModel.hasMore ? 1 : 0
        return viewModel.currentCount + isLoadingCellGap
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: EntryCell.reusableIdentifier, for: indexPath) as! EntryCell
        
        if isLoadingCell(for: indexPath) {
            cell.configure(with: .none)
        } else {
            // This entry could be updated with mediaMetadata if it is either video or photo. Using reference semantic
            let entry = viewModel.entry(at:indexPath.row)
            let viewModel = EntryCellViewModel(metadata: entry, thumbnailService: DefaultThumbnailService(), thumbnailCache: viewModel.thumbnailCache)
            cell.configure(with: viewModel)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isLoadingCell(for: indexPath) { viewModel.fetchContent() }
    }
    
}

extension FolderContentViewController: UITableViewDelegate {
    private static let cellsOnTheScreen = 15
    private static let minRowHieght = 50.0
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let screenBounds = UIScreen.main.bounds
        let expectedRowHeight = max(screenBounds.height, screenBounds.width)/CGFloat(FolderContentViewController.cellsOnTheScreen)
        return max(expectedRowHeight, FolderContentViewController.minRowHieght)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let entry = viewModel.entry(at: indexPath.row)
        if let file = entry as? FileMetadata {
            coordinator?.entryViewer(file)
        } else if let folder = entry as? FolderMetadata {
            print("Should show folder content")
        }
//        let entry = viewModel.entries.value[indexPath.row]
//        coordinator?.entryDetails(entry)
//        showPlayer()
    }
    
}

private extension FolderContentViewController {
    
    private func showPlayer() {
        let video = "https://ucb2c283762843a12c63ff940dd0.dl.dropboxusercontent.com/cd/0/get/CC67Ylbpt5gOKdH0t7ZENp61rm_DjrNcWTHuLZZpETQ8utkpd_MZ59EibMoN-tv1A6zXvxjUf-jQN_va4OXjmQIErtgcrYQI7wCYpSP-72HI38enfAN4L_XCMS-X0kaEr2sypMC5V7yc2MFD8adk-PD0VSgqij8ESXB7qEFUqsTMhA/file"
        let videoPlayer = AVPlayer(url: URL(string: video)!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = videoPlayer
        self.present(playerViewController, animated: true) {
            if let player = playerViewController.player {
                player.play()
            }
        }
    }
}
