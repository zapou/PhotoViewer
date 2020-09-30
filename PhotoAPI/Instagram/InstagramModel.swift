//
//  InstagramModel.swift
//  PhotoAPI
//
//  Created by Pierre on 30/09/2020.
//

import Foundation

public class InstagramModel: BaseModel {
    init(height: Int, width: Int, url: String?, title: String) {
        super.init()
        self.height = height
        self.width = width
        self.url = url
        self.title = title
    }
}
