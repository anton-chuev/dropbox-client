//
//  SignInViewController.swift
//  dropbox-client
//
//  Created by Anton Chuev on 01.09.2023.
//

import UIKit

final class SignInViewController: UIViewController {

    private var viewModel: SignInViewModel!
    
    static func create(with viewModel: SignInViewModel) -> SignInViewController {
        let vc = SignInViewController()
        vc.viewModel = viewModel
        return vc
    }
    
    @IBAction func signInTapped(sender: UIButton) {
        viewModel.authorize(from: self)
    }

}
