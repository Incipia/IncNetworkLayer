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
