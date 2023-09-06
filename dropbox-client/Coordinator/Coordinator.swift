//
//  Coordinator.swift
//  dropbox-client
//
//  Created by Anton Chuev on 31.08.2023.
//

import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
    func showAlert(title: String?, message: String?)
}

extension Coordinator {
    func showAlert(title: String?, message: String?) {
        showAlertController(title: title, message: message, style: .alert)
    }
    
    func showActionSheet(title: String?, message: String?) {
        showAlertController(title: title, message: message, style: .actionSheet)
    }
    
    private func showAlertController(title: String?, message: String?, style: UIAlertController.Style) {
        guard let topController = navigationController.topViewController else {
            return
        }

        let dialogMessage = UIAlertController(title: title, message: message, preferredStyle: style)

        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        dialogMessage.addAction(ok)

        topController.present(dialogMessage, animated: true, completion: nil)
    }
}
