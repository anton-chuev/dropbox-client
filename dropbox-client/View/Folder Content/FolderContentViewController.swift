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
    private weak var coordinator: (Coordinator & ShowingEntryDetails & PopingToSignIn)?
    
    // MARK: - Fabric method
    static func create(with viewModel: FolderContentViewModel,
                       coordinator: (Coordinator & ShowingEntryDetails & PopingToSignIn)) -> FolderContentViewController {
        let vc = FolderContentViewController()
        vc.viewModel = viewModel
        vc.coordinator = coordinator as? MainCoordinator
        return vc
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        title = "Files"
        
        navigationItem.rightBarButtonItem = signOutBarButton()
        navigationItem.setHidesBackButton(true, animated: false)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(EntryCell.nib, forCellReuseIdentifier: EntryCell.reusableIdentifier)
        tableView.isHidden = true
        
        // Remove the extra empty cell divider lines
        tableView.tableFooterView = UIView()
        
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
        
        viewModel.deletedEntryIndex.bind { [weak self] index in
            guard let index = index else { return }
            self?.tableView.beginUpdates()
            self?.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
            self?.tableView.endUpdates()
        }
        
        viewModel.didSignOut.bind { [weak self] signedOut in
            if signedOut { self?.coordinator?.popToSignIn() }
        }
        
    }
    
    @objc private func loadFirstPage() {
        viewModel.resetCursor()
        viewModel.fetchContent()
    }
    
    @objc private func signOutTapped() {
        viewModel.signOut()
    }
    
    private func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return viewModel.hasMore && indexPath.row >= viewModel.currentCount
    }
    
    private func signOutBarButton() -> UIBarButtonItem {
        let signOutButton = UIButton(type: .custom)
        signOutButton.setImage(UIImage(systemName: "rectangle.portrait.and.arrow.right"), for: .normal)
        signOutButton.addTarget(self, action:#selector(signOutTapped), for: .touchUpInside)
        return UIBarButtonItem(customView: signOutButton)
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        guard editingStyle == .delete else { return }
        viewModel.deleteEntry(at: indexPath.row)
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
        } else if let _ = entry as? FolderMetadata {
            // TODO: Show selected folder's content
        }
    }
    
}
