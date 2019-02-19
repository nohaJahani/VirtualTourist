//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by نهى on 20/05/1440 AH.
//  Copyright © 1440 Noha. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    //let dataController = DataController(modelName: "VirtualTouristModel")
    
    let dataController = DataController(modelName: "VirtualTouristModel")
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        dataController.load()
   
        
        let navigationController = window?.rootViewController as! UINavigationController
        let TravelLocationsMapViewController = navigationController.topViewController as! TravelLocationsMapViewController
        TravelLocationsMapViewController.dataController = dataController
        
        return true
    }
    
    
    func saveViewContext() {
        try? dataController.viewContext.save()
    }
}

