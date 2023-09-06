//
//  LogoutServiceMock.swift
//  dropbox-clientTests
//
//  Created by Anton Chuev on 06.09.2023.
//

@testable import dropbox_client

final class LogoutServiceMock: LogoutService {
    var logoutGotCalled = false
    
    func logout() {
        logoutGotCalled = true
    }
}
