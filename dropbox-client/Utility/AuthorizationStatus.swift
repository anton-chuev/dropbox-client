//
//  AuthorizationStatus.swift
//  dropbox-client
//
//  Created by Anton Chuev on 01.09.2023.
//

import SwiftyDropbox

struct AuthorizationStatus {
    static var isAutorized: Bool { DropboxClientsManager.authorizedClient != nil }
}
