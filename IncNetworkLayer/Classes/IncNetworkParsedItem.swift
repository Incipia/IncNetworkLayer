import Foundation

public protocol IncNetworkParsedItem {}

public protocol IncNetworkDataInitable: IncNetworkParsedItem {
   init?(with data: Data) throws
}

public protocol IncNetworkJSONInitable: IncNetworkParsedItem {
   init?(with json: Any) throws
}
