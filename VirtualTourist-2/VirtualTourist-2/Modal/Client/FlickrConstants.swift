//
//  FlickrConstants.swift
//  VirtualTourist
//
//  Created by نهى on 27/05/1440 AH.
//  Copyright © 1440 Noha. All rights reserved.
//

import Foundation

// MARK: - TMDBClient (Constants)

extension FlickrClient {
    
    // MARK: Constants
    struct Constants {
        
        // MARK: API Keys
        static let ApiKey = "0b9e701fe05f1337cf1e2f09f8f266b4"
        
        
        // MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "api.flickr.com"
        static let ApiPath = "/services/rest"
        
        
        //bbox
        static let bboxWidth = 1.0
        static let bboxHeight = 1.0
        static let minLat = -90.0
        static let maxLat = 90.0
        static let minLong = -180.0
        static let maxLong = 180.0
        
        
    }
    
    // MARK: Methods
    struct Methods {
        
        static let PhotoSearch = "flickr.photos.search"
    }
    
    
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        static let Method = "method"
        static let ApiKey = "api_key"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let bbox = "bbox"
        static let Pages = "pages"
        static let PerPage = "per_page"
        static let Page = "page"
        static let HasGeo = "has_geo"
        static let GeoContext = "geo_context"
       static let Accuracy = "accuracy"
    }
    
    
    struct ParameterValues {
        static let SafeSearch = "1"
        static let Extras = "url_m"
        static let Format = "json"
        static let NoJSONCallback = "1"
          static let PerPage = "20"
        static let Has = "1"
        static let GeoContext = "0"
        static let Accuracy = "16"
    }
    
    // MARK: JSON Response Keys
    
    struct JSONResponseKeys {
        static let Photos = "photos"
        static let Photo = "photo"
        
    }
    
    
}

