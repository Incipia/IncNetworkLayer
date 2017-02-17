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
   
   func testRoute() {
         let routeOperation = RouteOperation(start: "here", end: "Shell Beach")
      routeOperation.success = { routeItem in
         XCTAssertNotNil(routeItem)
         print("Route item: \(routeItem)")
      }
      routeOperation.failure = { error in
         XCTFail()
         print("Route error: \(error.localizedDescription)")
      }
      IncNetworkQueue.shared.addOperation(routeOperation)
   }
}
