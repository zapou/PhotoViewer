//
//  FlickerManager.swift
//  PhotoAPI
//
//  Created by Pierre on 30/09/2020.
//

import Foundation

public class FlickrManager: PhotoManager {
    let BASE_URL = "https://api.flickr.com/services/rest/"
    let METHOD_NAME:String! = "flickr.photos.search"
    let API_KEY:String! = "0113cd40ff76104858514beaca69347b"
    let GALLERY_ID:String! = "5704-72157622566655097"
    let EXTRAS:String! = "url_m"
    let DATA_FORMAT:String! = "json"
    let SAFE_SEARCH:String!="1"
    let NO_JSON_CALLBACK:String! = "1"
    
    
    override public func getData(closure: @escaping (([BaseModel]) -> ())) {
        let methodArguments = [
            "method": METHOD_NAME,
            "api_key": API_KEY,
            "text": "landscape",
            "safe_search": SAFE_SEARCH,
            "extras": EXTRAS,
            "format": DATA_FORMAT,
            "nojsoncallback": NO_JSON_CALLBACK
        ]
        
        let urlString = BASE_URL + escapedParameters(parameters: methodArguments)
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) {data, response, downloadError in
            if let error = downloadError {
                print("Could not complete the request \(error)")
            } else {
                var parsingError: NSError?
                var item = [FlickrModel]()
                var parsedResult: AnyObject!
                do {
                    parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as AnyObject
                    if let photos = parsedResult["photos"] as? NSDictionary {
                        if let listPhoto = photos["photo"] as? Array<[String:Any]> {
                            for value in listPhoto {
                                item.append(FlickrModel(dictionnary: value))
                            }
                        }
                    }
                } catch let error as NSError {
                    parsingError = error
                    print(parsingError.debugDescription)
                } catch {
                    fatalError()
                }
                closure(item.filter({ $0.url != nil }))
            }
        }
        task.resume()
    }
    
    private func escapedParameters(parameters: [String : String?]) -> String! {
        var urlVars = [String]()
        
        for (key, value) in parameters {
            let escapedValue = value!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            urlVars += [key + "=" + "\(escapedValue!)"]
        }
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joined(separator: "&")
    }
    
}
