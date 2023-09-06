//
//  LoginViewController.swift
//  dropbox-client
//
//  Created by Anton Chuev on 01.09.2023.
//

import UIKit

final class LoginViewController: UIViewController {

    private var viewModel: LoginViewModel!
    
    static func create(with viewModel: LoginViewModel) -> LoginViewController {
        let vc = LoginViewController()
        vc.viewModel = viewModel
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login"
        navigationItem.largeTitleDisplayMode = .never
    }
    
    @IBAction func loginTapped(sender: UIButton) {
        viewModel.authorize(from: self)
    }

}
