//
//  AuthService.swift
//  dropbox-client
//
//  Created by Anton Chuev on 31.08.2023.
//

import UIKit
import SwiftyDropbox

protocol AuthService {
    func authorize(from controller: UIViewController)
}

struct DefaultAuthService: AuthService {
    func authorize(from controller: UIViewController) {
        DropboxClientsManager.authorizeFromControllerV2(
            UIApplication.shared,
            controller: controller,
            loadingStatusDelegate: nil,
            openURL: {(url: URL) -> Void in
                UIApplication.shared.open(url)
            },
            scopeRequest: ScopeRequest(scopeType: .user,
                                       scopes: ["files.metadata.read", "files.content.read",           "files.content.write"],
                                       includeGrantedScopes: false))
    }
}
