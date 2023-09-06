//
//  LoginViewModelTests.swift
//  dropbox-clientTests
//
//  Created by Anton Chuev on 06.09.2023.
//

import XCTest
@testable import dropbox_client

final class LoginViewModelTests: XCTestCase {
    var vm: LoginViewModel!
    var authService: AuthServiceMock!
    
    override func setUp() {
        authService = AuthServiceMock()
        vm = LoginViewModel(authService: authService)
    }
    
    func test_auth_should_be_called() async {
        let mockVC = await UIViewController()
        vm.authorize(from: mockVC)
        
        XCTAssertEqual(authService.authorizeGotCalledWith, (mockVC))
        XCTAssertNil(vm.errorMessage.value)
    }

}
