import Foundation

public protocol IncNetworkParsedItem {}

public protocol IncNetworkDataInitable: IncNetworkParsedItem {
   init?(data: Data) throws
}

public protocol IncNetworkJSONInitable: IncNetworkParsedItem {
   init?(json: Any) throws
}
