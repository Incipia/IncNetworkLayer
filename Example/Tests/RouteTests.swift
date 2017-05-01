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

}
