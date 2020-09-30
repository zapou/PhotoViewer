//
//  BaseModel.swift
//  PhotoAPI
//
//  Created by Pierre on 30/09/2020.
//

import Foundation

public class BaseModel {
    public var height: Int
    public var width: Int
    public var title: String
    public var url: String?
    
    init() {
        height = Int()
        width = Int()
        title = String()
        url = nil
    }
}
