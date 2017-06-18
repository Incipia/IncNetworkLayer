//
//  RouteTests.swift
//  IncNetworkLayer
//
//  Created by Leif Meyer on 2/16/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
@testable import IncNetworkLayer

class RouteTests: XCTestCase {
   
   override func setUp() {
      super.setUp()
      let testBundle = Bundle(for: RouteTests.self)
      let resourceURL = testBundle.resourceURL;
      IncNetworkRequestConfiguration.shared = IncNetworkRequestConfiguration(baseURL: resourceURL!)
      IncNetworkQueue.shared = IncNetworkQueue()
   }
   
   override func tearDown() {
      // Put teardown code here. This method is called after the invocation of each test method in the class.
      super.tearDown()
   }
   
   func testRouteOperation() {
      let routeOperation = RouteOperation(start: "here", end: "Shell Beach")
      routeOperation.completion = { result in
         switch result {
         case .success(let routeItem):
            XCTAssertNotNil(routeItem)
            print("Route item: \(routeItem)")
         case .nullSuccess:
            XCTFail()
            print("Route item was not retrieved")
         case .error(_, let error), .failure(let error):
            XCTFail()
            print("Route error: \(error.localizedDescription)")
         }
      }
      IncNetworkQueue.shared.addOperation(routeOperation)
   }

   func testRouteParameterOperation() {
      let routeParameter = RouteParameter(start: "here", end: "Shell Beach")
      let routeOperation = RouteParameterOperation(parameter: routeParameter)
      routeOperation.completion = { result in
         switch result {
         case .success(let routeItem):
            XCTAssertNotNil(routeItem)
            print("Route item: \(routeItem)")
         case .nullSuccess:
            XCTFail()
            print("Route item was not retrieved")
         case .error(_, let error), .failure(let error):
            XCTFail()
            print("Route error: \(error.localizedDescription)")
         }
      }
      IncNetworkQueue.shared.addOperation(routeOperation)
   }

   func testRouteObjectOperation() {
      let routeParameter = RouteParameter(start: "here", end: "Shell Beach")
      let routeOperation = RouteObjectOperation(parameter: routeParameter)
      routeOperation.completion = { result in
         switch result {
         case .success(let routeItem):
            XCTAssertNotNil(routeItem)
            print("Route item: \(routeItem)")
         case .nullSuccess:
            XCTFail()
            print("Route item was not retrieved")
         case .error(_, let error), .failure(let error):
            XCTFail()
            print("Route error: \(error.localizedDescription)")
         }
      }
      IncNetworkQueue.shared.addOperation(routeOperation)
   }

   func testNotification() {
      let observer = RouteActivityObserver()
      observer.startObserving(notification: IncNetworkQueue.Notification.startedNetworkActivity, object: IncNetworkQueue.shared)
      XCTAssertEqual(observer.startedCount, 0)
      XCTAssertEqual(observer.stoppedCount, 0)
      let routeOperation = RouteOperation(start: "here", end: "Shell Beach")
      
      routeOperation.completion = { _ in
         XCTAssertEqual(observer.startedCount, 1)
         XCTAssertEqual(observer.stoppedCount, 0)
      }
      expectation(forNotification: IncNetworkQueue.Notification.stoppedNetworkActivity.name.rawValue, object: IncNetworkQueue.shared)
      IncNetworkQueue.shared.addOperation(routeOperation)
      waitForExpectations(timeout: 0.5)
   }
   
   func testOperationNotification() {
      let observer = RouteActivityObserver()
      let onObserverExpectation = expectation(description: "onObserver executed")
      observer.onObserve = { notification in
         onObserverExpectation.fulfill()
         switch notification {
         case .operationStarted(let op): XCTAssert(op is RouteOperation)
         default: XCTFail()
         }
      }
      observer.startObserving(notification: IncNetworkQueue.Notification.operationStarted(nil), object: IncNetworkQueue.shared)
      XCTAssertEqual(observer.startedCount, 0)
      XCTAssertEqual(observer.stoppedCount, 0)
      XCTAssertEqual(observer.opStartCount, 0)
      let routeOperation = RouteOperation(start: "here", end: "Shell Beach")
      
      routeOperation.completion = { _ in
         XCTAssertEqual(observer.startedCount, 0)
         XCTAssertEqual(observer.stoppedCount, 0)
         XCTAssertEqual(observer.opStartCount, 1)
      }
      expectation(forNotification: IncNetworkQueue.Notification.operationStarted(nil).name.rawValue, object: IncNetworkQueue.shared)
      IncNetworkQueue.shared.addOperation(routeOperation)
      waitForExpectations(timeout: 0.5)
   }
}
