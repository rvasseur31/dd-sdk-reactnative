/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2019-2020 Datadog, Inc.
 */

import XCTest
@testable import DatadogSDKReactNativeSessionReplay
import DatadogSessionReplay
import React

internal class DdSessionReplayTests: XCTestCase {
    private func mockResolve(args: Any?) {}
    private func mockReject(args: String?, arg: String?, err: Error?) {}
 
    func testEnablesSessionReplayWithZeroReplaySampleRate() {
        let sessionReplayMock = MockSessionReplay()
        let uiManagerMock = MockUIManager()
        DdSessionReplayImplementation(sessionReplayProvider:{ sessionReplayMock }, uiManager: uiManagerMock)
            .enable(replaySampleRate: 0, defaultPrivacyLevel: "MASK", customEndpoint: "", resolve: mockResolve, reject: mockReject)
        
        XCTAssertEqual(sessionReplayMock.calledMethods.first, .enable(replaySampleRate: 0.0, privacyLevel: .mask, customEndpoint: nil))
    }
    
    func testEnablesSessionReplayWithMaskPrivacyLevel() {
        let sessionReplayMock = MockSessionReplay()
        let uiManagerMock = MockUIManager()
        DdSessionReplayImplementation(sessionReplayProvider:{ sessionReplayMock }, uiManager: uiManagerMock)
            .enable(replaySampleRate: 100, defaultPrivacyLevel: "MASK", customEndpoint: "", resolve: mockResolve, reject: mockReject)
        
        XCTAssertEqual(sessionReplayMock.calledMethods.first, .enable(replaySampleRate: 100.0, privacyLevel: .mask, customEndpoint: nil))
    }
    
    func testEnablesSessionReplayWithMaskUserInputPrivacyLevel() {
        let sessionReplayMock = MockSessionReplay()
        let uiManagerMock = MockUIManager()
        DdSessionReplayImplementation(sessionReplayProvider:{ sessionReplayMock }, uiManager: uiManagerMock)
            .enable(replaySampleRate: 100, defaultPrivacyLevel: "MASK_USER_INPUT", customEndpoint: "", resolve: mockResolve, reject: mockReject)
        
        XCTAssertEqual(sessionReplayMock.calledMethods.first, .enable(replaySampleRate: 100.0, privacyLevel: .maskUserInput, customEndpoint: nil))
    }
    
    func testEnablesSessionReplayWithAllowPrivacyLevel() {
        let sessionReplayMock = MockSessionReplay()
        let uiManagerMock = MockUIManager()
        DdSessionReplayImplementation(sessionReplayProvider:{ sessionReplayMock }, uiManager: uiManagerMock)
            .enable(replaySampleRate: 100, defaultPrivacyLevel: "ALLOW", customEndpoint: "", resolve: mockResolve, reject: mockReject)
        
        XCTAssertEqual(sessionReplayMock.calledMethods.first, .enable(replaySampleRate: 100.0, privacyLevel: .allow, customEndpoint: nil))
    }
    
    func testEnablesSessionReplayWithBadPrivacyLevel() {
        let sessionReplayMock = MockSessionReplay()
        let uiManagerMock = MockUIManager()
        DdSessionReplayImplementation(sessionReplayProvider:{ sessionReplayMock }, uiManager: uiManagerMock)
            .enable(replaySampleRate: 100, defaultPrivacyLevel: "BAD_VALUE", customEndpoint: "", resolve: mockResolve, reject: mockReject)
        
        XCTAssertEqual(sessionReplayMock.calledMethods.first, .enable(replaySampleRate: 100.0, privacyLevel: .mask, customEndpoint: nil))
    }
    
    func testEnablesSessionReplayWithCustomEndpoint() {
        let sessionReplayMock = MockSessionReplay()
        let uiManagerMock = MockUIManager()
        DdSessionReplayImplementation(sessionReplayProvider:{ sessionReplayMock }, uiManager: uiManagerMock)
            .enable(replaySampleRate: 100, defaultPrivacyLevel: "MASK", customEndpoint: "https://session-replay.example.com", resolve: mockResolve, reject: mockReject)
        
        XCTAssertEqual(sessionReplayMock.calledMethods.first, .enable(replaySampleRate: 100.0, privacyLevel: .mask, customEndpoint: URL(string: "https://session-replay.example.com/api/v2/replay")))
    }
}

private class MockSessionReplay: SessionReplayProtocol {
    enum CalledMethod: Equatable {
        case enable(replaySampleRate: Float, privacyLevel: SessionReplay.Configuration.PrivacyLevel, customEndpoint: URL?)
    }

    public var calledMethods = [CalledMethod]()

    func enable(with configuration: SessionReplay.Configuration) {
        calledMethods.append(
            .enable(
                replaySampleRate: configuration.replaySampleRate,
                privacyLevel: configuration.defaultPrivacyLevel,
                customEndpoint: configuration.customEndpoint
            )
        )
    }
}

private class MockUIManager: RCTUIManager {}
