//
//  EntryCell.swift
//  dropbox-client
//
//  Created by Anton Chuev on 31.08.2023.
//

import UIKit

protocol Registerable {
    static var nib: UINib { get }
}

protocol Reusable {
    static var reusableIdentifier: String { get }
}

final class EntryCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var viewModel: EntryCellViewModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        icon?.clipsToBounds = true
        icon?.contentMode = .scaleAspectFit
    }
    
    func bind(to viewModel: EntryCellViewModel) {
        viewModel.imageData.bind { [weak self] data in
            if data != nil {
                DispatchQueue.main.async {
                    self?.icon.image = UIImage(data: data!)
                }
            }
        }
        viewModel.entryName.bind { [weak self] name in
            if let name = name {
                DispatchQueue.main.async {
                    self?.name.text = name
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        configure(with: .none)
    }
    
    func configure(with viewModel: EntryCellViewModel?) {
        if let viewModel = viewModel {
            self.viewModel = viewModel
            bind(to: viewModel)
            viewModel.initialSetup()
            viewModel.getThumbnail()
            name.alpha = 1
            icon.alpha = 1
            activityIndicator.stopAnimating()
        } else {
            name.alpha = 0
            icon.alpha = 0
            activityIndicator.startAnimating()
        }
    }
    
}

extension EntryCell: Registerable, Reusable {
    static var nib: UINib { UINib(nibName: "EntryCell", bundle: nil) }
    static var reusableIdentifier: String { "EntryCell" }
}
