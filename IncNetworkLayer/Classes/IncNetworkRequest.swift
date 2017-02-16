import Foundation

protocol IncNetworkRequest {
    var endpoint: String { get }
    var method: IncNetworkService.Method { get }
    var query: IncNetworkService.QueryType { get }
    var parameters: [String: Any]? { get }
    var headers: [String: String]? { get }
}

extension IncNetworkRequest {
    
    func defaultJSONHeaders() -> [String: String] {
        return ["Content-Type": "application/json"]
    }
}
