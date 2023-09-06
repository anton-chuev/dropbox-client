//
//  LogoutService.swift
//  dropbox-client
//
//  Created by Anton Chuev on 01.09.2023.
//

import SwiftyDropbox

protocol LogoutService {
    func logout()
}

struct DefaultLogoutService: LogoutService {
    func logout() {
        DropboxClientsManager.unlinkClients()
    }
}
