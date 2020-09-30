//
//  ApiManager.swift
//  PhotoViewerUITests
//
//  Created by Pierre on 29/09/2020.
//

import Foundation

public enum Api: String {
    case Flickr = "Flickr"
    case Instagram = "Instagram"
}

protocol ApiRequirements {
    func getData(closure: @escaping (([BaseModel]) -> ()))
}


public class PhotoManager: ApiRequirements {
   public func getData(closure: @escaping (([BaseModel]) -> ())) {
        
    }
}
public class ApiManager: NSObject {
    private var api: Api!
    public var manager: PhotoManager!
    public init(api: Api) {
        self.api = api
        super.init()
        
        switch api {
        case .Flickr:
            self.manager = FlickrManager()
        case .Instagram:
            self.manager = InstagramManager()
        }
    }
    
    public func getDescription() -> String {
        return self.api!.rawValue
    }
    
}

