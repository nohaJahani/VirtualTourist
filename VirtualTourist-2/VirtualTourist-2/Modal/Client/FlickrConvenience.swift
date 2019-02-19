//
//  FlickrConvenience.swift
//  VirtualTourist
//
//  Created by نهى on 27/05/1440 AH.
//  Copyright © 1440 Noha. All rights reserved.
//

import Foundation
import UIKit

// MARK: - FlickrClient (Convenient Resource Methods)

extension FlickrClient {
    
    
    private func createbbox(pin: Pin) -> String {
        
        let minLongitude = max(pin.longitude - FlickrClient.Constants.bboxWidth, FlickrClient.Constants.minLong)
        let minLatitude =  max(pin.latitude - FlickrClient.Constants.bboxHeight, FlickrClient.Constants.minLat)
        let maxLongitude = min(pin.longitude + FlickrClient.Constants.bboxWidth, FlickrClient.Constants.maxLong)
        let maxLatitude = min(pin.latitude + FlickrClient.Constants.bboxHeight, FlickrClient.Constants.maxLat)
        
        return "\(minLongitude),\(minLatitude),\(maxLongitude),\(maxLatitude)"
    }
    
    
    // MARK: GET Convenience Methods
    
    func photoAlbumSearch(pin: Pin , completionHandler: @escaping (_ result: [String: AnyObject]?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        
        var pageNumber = 1
        
        for _ in 1...300 {
            pageNumber = Int((arc4random_uniform(UInt32(pin.totalPages)))) + 1
        }
        
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        
        let parametersWithKeys: [String:Any] = [
            ParameterKeys.Method: Methods.PhotoSearch,
            ParameterKeys.ApiKey: Constants.ApiKey,
            ParameterKeys.Extras: ParameterValues.Extras,
            ParameterKeys.Format: ParameterValues.Format,
            ParameterKeys.NoJSONCallback: ParameterValues.NoJSONCallback,
            ParameterKeys.SafeSearch: ParameterValues.SafeSearch,
            ParameterKeys.PerPage:ParameterValues.PerPage,
            ParameterKeys.Page: pageNumber ,
            ParameterKeys.GeoContext: ParameterValues.GeoContext,
            ParameterKeys.HasGeo: ParameterValues.Has,
            ParameterKeys.Accuracy: ParameterValues.Accuracy,
            ParameterKeys.bbox: createbbox(pin: pin)
        ]
        
        /* 2. Make the request */
        
        let task = taskForGETMethod("", parameters: parametersWithKeys as [String : AnyObject]) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            
            if let error = error {
                completionHandler( nil, error)
            }
            else if results == nil {
                completionHandler(nil, error)
            }
            else {
                let results = results as! [String: AnyObject]
                completionHandler(results, nil)
            }
            
        }
        
        return task
    }
    
    func downloadPhoto(_ imageUrl: String, completionHandler: @escaping (_ data: Data?, _ errorString: String?) -> Void) {
        let session = URLSession.shared
        let imageURL = URL(string: imageUrl)
        let request: URLRequest = URLRequest(url: imageURL! as URL)
        
        let task = session.dataTask(with: request as URLRequest) {data, response, error in
            
            if error != nil {
                completionHandler(nil, "Could not download image \(imageUrl)")
            } else {
                
                completionHandler(data, nil)
            }
        }
        
        task.resume()
    }
    
}
