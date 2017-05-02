import Foundation

public protocol IncNetworkMapper {
   associatedtype Item
   static func process(_ obj: Any?) throws -> Item?
}

public enum IncNetworkMapperError: Error {
   case invalid
   case nulItem
   case itemInitFailed
   case invalidAttribute(name: String)
}
