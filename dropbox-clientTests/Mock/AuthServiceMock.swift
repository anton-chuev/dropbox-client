//
//  AuthServiceMock.swift
//  dropbox-clientTests
//
//  Created by Anton Chuev on 06.09.2023.
//

import UIKit
@testable import dropbox_client

class AuthServiceMock: AuthService {
    var authorizeGotCalledWith = (UIViewController())
    
    func authorize(from controller: UIViewController) {
        authorizeGotCalledWith = (controller)
    }
}
