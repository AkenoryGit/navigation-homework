//
//  FeedViewModelTests.swift
//  NavigationTests
//
//  Created by Дмитрий Дудник on 24.10.2025.
//

import XCTest
@testable import Navigation

class FeedViewModelTests: XCTestCase {
    var viewModel: FeedViewModel!

    override func setUp() {
        super.setUp()
        viewModel = FeedViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func testCheckWordSuccess() {
        let result = viewModel.check(word: "secret")
        XCTAssertTrue(result, "Check should return true for correct password 'secret'")
    }

    func testCheckWordFailure() {
        let result = viewModel.check(word: "wrong")
        XCTAssertFalse(result, "Check should return false for incorrect password 'wrong'")
    }

    func testCheckWordEmpty() {
        let result = viewModel.check(word: "")
        XCTAssertFalse(result, "Check should return false for empty input")
    }
}
