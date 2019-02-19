//
//  TravelLocationsMapViewController.swift
//  VirtualTourist
//
//  Created by نهى on 20/05/1440 AH.
//  Copyright © 1440 Noha. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController  {
    
    // MARK: Outlet
    
    @IBOutlet weak var mapView: MKMapView!
    // MARK: Properties
    
    var dataController: DataController!
    var pinFetchedResultsController: NSFetchedResultsController<Pin>!
    
    fileprivate func setupFetchResultsController() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchRequest.sortDescriptors = []
        pinFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "Pins")
        do {
            try pinFetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not perform: \(error.localizedDescription)")
        }
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //long press
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        mapView.addGestureRecognizer(longTapGesture)
        
        setupFetchResultsController()
        
        centerMapRegion()
        
        fetchAllPins()
        
    }
    
    
    // MARK: prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PhotoAlbumSegue" {
            let controller = segue.destination as! PhotoAlbumViewController
            
            let pin = sender as! Pin
            controller.pin = pin
            
            controller.dataController = dataController
        }
    }
    
    // long tap to add pin on the map
    @objc func longTap(sender: UIGestureRecognizer){
        
        if sender.state == .began {
            //setupFetchResultsController()
            addPin(at: sender.location(in: mapView))
            setupFetchResultsController()
            
        }
    }
    
    //add pin on the map and save to CoreData
    
    func addPin(at locationInView: CGPoint) {
        
        let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationOnMap
        mapView.addAnnotation(annotation)
        
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = locationOnMap.latitude
        pin.longitude = locationOnMap.longitude
        try? dataController.viewContext.save()
        
    }
    
    // fetch all the pins from CoreData
    
    func fetchAllPins() {
        let pins = pinFetchedResultsController.fetchedObjects!
        
        var annotations = [MKAnnotation]()
        
        for pin in pins {
            
            let lat = CLLocationDegrees(pin.latitude)
            let long = CLLocationDegrees(pin.longitude)
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotations.append(annotation)
        }
        
        self.mapView.addAnnotations(annotations)
    }
    
    //fetch a pin from CoreData
    
    func fetchPin(with annotation: MKAnnotation) -> Pin? {
        
        let latitude = annotation.coordinate.latitude
        let longitude = annotation.coordinate.longitude
        
        var pin = Pin()
        
        if  let pins = pinFetchedResultsController.fetchedObjects {
            
            for pinLocation in pins {
                if pinLocation.latitude == latitude && pinLocation.longitude == longitude {
                    pin = pinLocation
                }
            }
        }
        return pin
        
    }
    
    // center Map
    
    func centerMapRegion() {
        
        if let mapRegion = UserDefaults.standard.dictionary(forKey: "mapRegion") {
            
            let center = CLLocationCoordinate2DMake(mapRegion["lat"] as! Double, mapRegion["long"] as! Double)
            let span = MKCoordinateSpan(latitudeDelta: mapRegion["latDelta"] as! Double, longitudeDelta: mapRegion["longDelta"] as! Double)
            
            let region = MKCoordinateRegion(center: center, span: span)
            
            mapView.setRegion(region, animated: true)
        }
    }
}

// MARK: - TravelLocationsMapViewController: MKMapViewDelegate

extension TravelLocationsMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            pinView?.animatesDrop = true
            
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        view.setSelected(true, animated: true)
        
        guard let pin = fetchPin(with: view.annotation!)  else{
            
            return
        }
        
        performSegue(withIdentifier: "PhotoAlbumSegue", sender: pin)
        
        mapView.deselectAnnotation(view.annotation, animated: true)
        
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        UserDefaults.standard.set(["lat": mapView.centerCoordinate.latitude
            , "long": mapView.centerCoordinate.longitude
            , "latDelta": mapView.region.span.latitudeDelta
            , "longDelta": mapView.region.span.longitudeDelta] , forKey: "mapRegion")
    }
    
}
