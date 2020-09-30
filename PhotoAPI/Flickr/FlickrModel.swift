//
//  FlickrModel.swift
//  PhotoAPI
//
//  Created by Pierre on 29/09/2020.
//

import Foundation


public class FlickrModel: BaseModel {
    init(dictionnary: [String:Any]) {
        super.init()
        self.height = dictionnary["height_m"] as? Int ?? 0
        self.width = dictionnary["height_m"] as? Int ?? 0
        self.url =  dictionnary["url_m"] as? String ?? nil
        self.title = dictionnary["title"] as? String ?? ""
    }
}
