import UIKit
import XCTest
@testable import IncNetworkLayer

class Tests: XCTestCase {
   let baseURLString = "https://example.com/"
   override func setUp() {
      super.setUp()
      // Put setup code here. This method is called before the invocation of each test method in the class.
      IncNetworkRequestConfiguration.shared = IncNetworkRequestConfiguration(baseURL: URL(string: baseURLString)!)
   }
   
   override func tearDown() {
      // Put teardown code here. This method is called after the invocation of each test method in the class.
      super.tearDown()
   }
   
   func testJSONResource() {
      let testBundle = Bundle(for: Tests.self)
      XCTAssertNotNil(testBundle)
      print("test bundle: \(testBundle)")
      let resourceURL = testBundle.resourceURL;
      XCTAssertNotNil(resourceURL)
      print("resource URL: \(resourceURL)")
      let jsonURL = testBundle.url(forResource: "test-json", withExtension: "")
      XCTAssertNotNil(jsonURL)
      print("json URL: \(jsonURL)")
   }
   
   func testLocalNSURLDataTask() {
      let testBundle = Bundle(for: Tests.self)
      let jsonURL = testBundle.url(forResource: "test-json", withExtension: "")
      let request = URLRequest(url: jsonURL!)
      let session = URLSession.shared
      let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
         XCTAssertNil(error)
         XCTAssertNotNil(data)
         let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
         XCTAssertNotNil(json as Any)
         XCTAssertEqual(json!!["key"] as? String, "value")
         print("JSON data: \(json)")
      }
      task.resume()
   }
   
   func testBaseURL() {
      XCTAssertEqual(IncNetworkRequestConfiguration.shared.baseURL, URL(string: baseURLString))
   }
   
   func testExample() {
      // This is an example of a functional test case.
      XCTAssert(true, "Pass")
   }
   
   func testPerformanceExample() {
      // This is an example of a performance test case.
      self.measure() {
         // Put the code you want to measure the time of here.
      }
   }
   
}
