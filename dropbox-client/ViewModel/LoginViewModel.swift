//
//  LoginViewModel.swift
//  dropbox-client
//
//  Created by Anton Chuev on 01.09.2023.
//

import UIKit

final class LoginViewModel {
    private(set) var loggedIn = Observable<Bool>(false)
    private(set) var errorMessage = Observable<String?>(nil)
    
    private var authService: AuthService
    
    init(authService: AuthService) {
        self.authService = authService
    }
    
    func authorize(from controller: UIViewController) {
        authService.authorize(from: controller)
    }
}
