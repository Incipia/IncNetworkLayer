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
   public var contentTransferEncoding: String?
   
   public init(fileName: String, data: Data, contentType: String, contentTransferEncoding: String? = nil) {
      self.fileName = fileName
      self.data = data
      self.contentType = contentType
      self.contentTransferEncoding = contentTransferEncoding
   }
   
   public init(fileName: String, data: Data) {
      self.init(fileName: fileName, data: data, contentType: "application/octet-stream")
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
      var optionalBody: Data?
      if isURLEncoded {
         var optionalBodyString: String?
         do {
            optionalBodyString = try self.query(with: parameters)
         } catch {
            switch error {
            case IncNetworkRequestError.invalidQueryParameter(let name): throw IncNetworkRequestError.invalidBodyParameter(name: name)
            default: throw error
            }
         }
         if let bodyString = optionalBodyString {
            guard let data = bodyString.data(using: encoding) else { throw IncNetworkRequestError.invalidBody(encoding: encoding) }
            optionalBody = data
         }
      } else if let parameters = parameters, !parameters.isEmpty {
         var bodyDataParts: [Data] = []
         
         for param in parameters {
            var body = ""
            let paramName = param.key
            body += "Content-Disposition:form-data; name=\"\(paramName)\""
            if let fileParam = param.value as? IncNetworkFormFileParameter {
               body += "; filename=\"\(fileParam.fileName)\"\r\n"
               body += "Content-Type: \(fileParam.contentType)\r\n\r\n"
               if let contentTransferEncoding = fileParam.contentTransferEncoding {
                  body += "Content-Transfer-Encoding: \(contentTransferEncoding)\r\n\r\n"
               }

               guard var data = body.data(using: encoding) else { throw IncNetworkRequestError.invalidBody(encoding: encoding) }
               data.append(fileParam.data)
               bodyDataParts.append(data)
            } else {
               body += "\r\n\r\n\(param.value)"
               guard let data = body.data(using: encoding) else { throw IncNetworkRequestError.invalidBody(encoding: encoding) }
               bodyDataParts.append(data)
            }
         }
         
         let boundary = boundary ?? self.boundary(bodyParts: bodyDataParts)
         guard let initialBoundryData = "--\(boundary)\r\n".data(using: encoding),
         let midBoundryData = "\r\n--\(boundary)\r\n".data(using: encoding),
         let finalBoundryData = "\r\n--\(boundary)--".data(using: encoding) else { throw IncNetworkRequestError.invalidBody(encoding: encoding) }
         var data = Data()
         data.append(initialBoundryData)
         for (index, dataPart) in bodyDataParts.enumerated() {
            data.append(dataPart)
            if index < bodyDataParts.count - 1 {
               data.append(midBoundryData)
            }
         }
         data.append(finalBoundryData)
         optionalBody = data
      }
      
      guard let body = optionalBody else { return nil }
      print("request body: \(String(data: body, encoding: .ascii)!)")
      
      return body
   }

   public func boundary(bodyParts: [Data] = []) -> String {
      var boundary = "----WebKitFormBoundary7MA4YWxkTrZu0gW"
      var countDown = UInt32.max
      let bodyString = bodyParts.map { String(data: $0, encoding: .ascii)! }.joined()
      while bodyString.range(of: boundary) != nil, countDown > 0 {
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
