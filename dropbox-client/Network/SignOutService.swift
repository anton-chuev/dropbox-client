//
//  SignOutService.swift
//  dropbox-client
//
//  Created by Anton Chuev on 01.09.2023.
//

import SwiftyDropbox

protocol SignOutService {
    func signOut()
}

struct DefaultSignOutService: SignOutService {
    func signOut() {
        DropboxClientsManager.unlinkClients()
    }
}
