//
//  IncNetworkFormRequest.swift
//  IncNetworkLayer
//
//  Created by Gregory Klein on 7/6/17.
//

import Foundation

public struct IncNetworkFormFileParameter {
   public var fileName: String
   public var data: Data
   public var contentType: String
   
   public init(fileName: String, data: Data, contentType: String) {
      self.fileName = fileName
      self.data = data
      self.contentType = contentType
   }
}

public protocol IncNetworkFormRequest: IncNetworkRequest {}

extension IncNetworkFormRequest {
   public var method: IncNetworkService.Method { return .post }
   public var headers: [String : String]? { return defaultFormHeaders() }
   
   public func decode(data: Data?, response: URLResponse?) throws -> Any? {
      guard let data = data, !data.isEmpty else { return nil }
      let form = try JSONSerialization.jsonObject(with: data, options: [])
      return form
   }

   public func body(parameters: [String : Any]?, encoding: String.Encoding = .utf8, isURLEncoded: Bool = true, boundary: String? = nil) throws -> Data? {
      var boundary = boundary
      return try body(parameters: parameters, encoding: encoding, isURLEncoded: isURLEncoded, boundary: &boundary)
   }
   
   public func body(parameters: [String : Any]?, encoding: String.Encoding = .utf8, isURLEncoded: Bool = true, boundary: inout String?) throws -> Data? {
      var optionalBody: String?
      if isURLEncoded {
         do {
            optionalBody = try self.query(with: parameters)
         } catch {
            switch error {
            case IncNetworkRequestError.invalidQueryParameter(let name): throw IncNetworkRequestError.invalidBodyParameter(name: name)
            default: throw error
            }
         }
      } else if let parameters = parameters, !parameters.isEmpty {
         var bodyParts: [String] = []
         
         for param in parameters {
            var body = ""
            let paramName = param.key
            body += "Content-Disposition:form-data; name=\"\(paramName)\""
            if let fileParam = param.value as? IncNetworkFormFileParameter {
               let contentType = fileParam.contentType
               let fileContent = fileParam.data.base64EncodedString()
               body += "; filename=\"\(fileParam.fileName)\"\r\n"
               body += "Content-Type: \(contentType)\r\n\r\n"
               body += fileContent
            } else {
               body += "\r\n\r\n\(param.value)"
            }
            bodyParts.append(body)
         }
         
         let boundary = boundary ?? self.boundary(bodyParts: bodyParts)
         optionalBody = "--\(boundary)\r\n\(bodyParts.joined(separator: "\r\n--\(boundary)\r\n"))\r\n--\(boundary)--"
      }
      
      guard let body = optionalBody else { return nil }
      guard let data = body.data(using: encoding) else { throw IncNetworkRequestError.invalidBody(encoding: encoding) }
      
      return data
   }

   public func boundary(bodyParts: [String] = []) -> String {
      var boundary = "----WebKitFormBoundary7MA4YWxkTrZu0gW"
      var countDown = UInt32.max
      while bodyParts.joined().range(of: boundary) != nil, countDown > 0 {
         boundary = "----WebKitFormBoundary\(arc4random())"
         countDown -= 1
      }
      if countDown == 0 {
         print("Unique boundary could not be found for encoding form parameters for endpoint \(endpoint)")
      }
      return boundary
   }

   public func defaultFormHeaders(isURLEncoded: Bool = true, boundary: String? = nil) -> [String: String] {
      switch isURLEncoded {
      case true: return ["Content-Type": "application/x-www-form-urlencoded"]
      case false: return ["Content-Type" : "multipart/form-data; boundary=\(boundary ?? self.boundary())"]
      }
   }
}

public protocol IncNetworkJSONFormRequest: IncNetworkJSONRequest, IncNetworkFormRequest {}
public extension IncNetworkJSONFormRequest {
   var method: IncNetworkService.Method { return .post }
   
   func decode(data: Data?, response: URLResponse?) throws -> Any? {
      guard let data = data, !data.isEmpty else { return nil }
      let json = try JSONSerialization.jsonObject(with: data, options: [])
      return json
   }
}
