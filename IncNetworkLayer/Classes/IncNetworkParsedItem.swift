import Foundation

public protocol IncNetworkParsedItem {}

public protocol IncNetworkDataInitable: IncNetworkParsedItem {
   init?(with data: Data)
}

public protocol IncNetworkJSONInitable: IncNetworkParsedItem {
   init?(with json: Any)
}
