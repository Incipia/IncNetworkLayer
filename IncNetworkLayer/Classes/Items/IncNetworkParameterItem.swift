//
//  IncNetworkParameterItem.swift
//  Pods
//
//  Created by Leif Meyer on 2/23/17.
//
//

public protocol IncNetworkParameterItem {}

public protocol IncNetworkDataRepresentable: IncNetworkParameterItem {
   var dataRepresentation: Data? { get }
}

public protocol IncNetworkJSONRepresentable: IncNetworkParameterItem {
   var jsonRepresentation: Any? { get }
}

public protocol IncNetworkFormRepresentable: IncNetworkParameterItem {
   var formRepresentation: [String : Any]? { get }
}

public protocol IncNetworkFormValueRepresentable: IncNetworkParameterItem {
   var formValueRepresentation: Any? { get }
}

public protocol IncNetworkDictionaryRepresentable: IncNetworkFormRepresentable {
   var dictionaryRepresentation: [String : Any]? { get }
   func formParameters(key: String, value: Any) -> [String : Any]?
}

public extension IncNetworkDictionaryRepresentable {
   var formRepresentation: [String : Any]? {
      guard let dictionary = dictionaryRepresentation, !dictionary.isEmpty else { return formParameters(parameters: nil) }
      
      var form: [String : Any] = [:]
      dictionary.forEach {
         guard self.formRepresentationIncludes(key: $0.key) else { return }
         if let parameters = self.formParameters(key: $0.key, value: $0.value) {
            parameters.forEach { form[$0.key] = $0.value }
         } else if let value = $0.value as? IncNetworkFormValueRepresentable {
            form[$0.key] = value.formValueRepresentation
         } else if let formValue = $0.value as? IncNetworkFormRepresentable {
            if let subForm = formValue.formRepresentation {
               subForm.forEach { form[$0.key] = $0.value }
            }
         } else {
            form[$0.key] = $0.value
         }
      }
      return formParameters(parameters: form)
   }
   
   func formRepresentationIncludes(key: String) -> Bool {
      return true
   }
   
   func formParameters(key: String, value: Any) -> [String : Any]? {
      return nil
   }
   
   func formParameters(parameters: [String : Any]?) -> [String : Any]? {
      return parameters
   }
}
