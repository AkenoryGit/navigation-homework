//
//  LoginViewModelTests.swift
//  NavigationTests
//
//  Created by Дмитрий Дудник on 24.10.2025.
//

import XCTest
@testable import Navigation

class LoginViewModelTests: XCTestCase {
    var loginInspector: LoginInspector!
    var mockCheckerService: MockCheckerService!
    
    override func setUp() {
        super.setUp()
        mockCheckerService = MockCheckerService()
        loginInspector = LoginInspector(checkerService: mockCheckerService)
    }
    
    override func tearDown() {
        loginInspector = nil
        mockCheckerService = nil
        super.tearDown()
    }
    
    func testCheckCredentialsSuccess() {
        mockCheckerService.shouldSucceed = true
        let expectation = XCTestExpectation(description: "Check credentials should succeed")
        
        loginInspector.checkCredentials(email: "test@example.com", password: "password123") { result in
            switch result {
            case .success():
                XCTAssertTrue(true, "Check credentials should succeed")
            case .failure:
                XCTFail("Check credentials should not fail")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testCheckCredentialsFailure() {
        mockCheckerService.shouldSucceed = false
        let expectation = XCTestExpectation(description: "Check credentials should fail")
        
        loginInspector.checkCredentials(email: "test@example.com", password: "wrong") { result in
            switch result {
            case .success():
                XCTFail("Check credentials should not succeed")
            case .failure:
                XCTAssertTrue(true, "Check credentials should fail")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}

class MockCheckerService: CheckerServiceProtocol {
    var shouldSucceed = false
    
    func checkCredentials(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        if shouldSucceed {
            completion(.success(()))
        } else {
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid credentials"])
            completion(.failure(error))
        }
    }
    
    func signUp(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        if shouldSucceed {
            completion(.success(()))
        } else {
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Sign up failed"])
            completion(.failure(error))
        }
    }
}
