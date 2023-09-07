//
//  SignOutServiceMock.swift
//  dropbox-clientTests
//
//  Created by Anton Chuev on 06.09.2023.
//

@testable import dropbox_client

final class SignOutServiceMock: SignOutService {
    var signOutGotCalled = false
    
    func signOut() {
        signOutGotCalled = true
    }
}
