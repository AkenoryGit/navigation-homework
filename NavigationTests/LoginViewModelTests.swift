//
//  LoginViewModelTests.swift
//  NavigationTests
//
//  Created by Дмитрий Дудник on 24.10.2025.
//

import XCTest
@testable import Navigation

class LoginViewModelTests: XCTestCase {

    func testCheckCredentialsSuccess() {
        let successMock = SuccessCheckerServiceMock()
        let inspector = LoginInspector(checkerService: successMock)
        
        let expectation = XCTestExpectation(description: "Check credentials should succeed")
        
        inspector.checkCredentials(email: "test@example.com", password: "any") { result in
            switch result {
            case .success():
                XCTAssertTrue(true)
            case .failure:
                XCTFail("Expected success, but got failure")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testCheckCredentialsFailure() {
        let failureMock = FailureCheckerServiceMock()
        let inspector = LoginInspector(checkerService: failureMock)
        
        let expectation = XCTestExpectation(description: "Check credentials should fail")
        
        inspector.checkCredentials(email: "test@example.com", password: "any") { result in
            switch result {
            case .success():
                XCTFail("Expected failure, but got success")
            case .failure(let error):
                XCTAssertNotNil(error)
                XCTAssertEqual((error as NSError).localizedDescription, "Invalid credentials")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}

private class SuccessCheckerServiceMock: CheckerServiceProtocol {
    func checkCredentials(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }
    
    func signUp(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }
}

private class FailureCheckerServiceMock: CheckerServiceProtocol {
    func checkCredentials(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid credentials"])
        completion(.failure(error))
    }
    
    func signUp(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Sign up failed"])
        completion(.failure(error))
    }
}
