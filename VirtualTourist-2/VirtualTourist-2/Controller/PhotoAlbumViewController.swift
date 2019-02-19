//
//  PhotoAlbumViewController.swift
//  VirtualTourist-2
//
//  Created by نهى on 07/06/1440 AH.
//  Copyright © 1440 Noha. All rights reserved.
//
import Foundation
import UIKit
import CoreData
import MapKit

class PhotoAlbumViewController: UIViewController {
    
    // MARK: Outlet
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var newCollectionButton: UIButton!
    
    @IBOutlet weak var removePictureButton: UIButton!
    
    
    // MARK: Properties
    
    var dataController: DataController!
    var pin: Pin!
    var selectedPicture = [IndexPath]()
    var photoFetchedResultsController:NSFetchedResultsController<Photo>!
    
    fileprivate func setupFetchedResultController() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        
        fetchRequest.sortDescriptors = []
        
        photoFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext:dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try photoFetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        removePictureButton.isHidden = true
        newCollectionButton.isHidden = false
        
        collectionView.allowsMultipleSelection = true
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(pin.latitude, pin.longitude)
        mapView.addAnnotation(annotation)
        mapView.setRegion(MKCoordinateRegion(center: annotation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)), animated: true)
        
        setupFetchedResultController()
        
        if photoFetchedResultsController.fetchedObjects?.count == 0 {
            photoAlbumSearch()
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupFetchedResultController()
        if photoFetchedResultsController.fetchedObjects?.count == 0 {
            photoAlbumSearch()
        }
    }
    
    // MARK: Actions
    
    @IBAction func newColleectionPressed(_ sender: Any) {
        
        deletePhotos()
        
        photoAlbumSearch()
    }
    
    
    @IBAction func removePicturePressed(_ sender: Any) {
        
        if collectionView.indexPathsForSelectedItems!.count > 0 {
            
            for indexPath in collectionView.indexPathsForSelectedItems! {
                let photo = self.photoFetchedResultsController!.object(at: indexPath)
                
                selectedPicture.forEach {
                    selectedPicture.remove(at:$0.row)
                }
                dataController.viewContext.delete(photo)
            }
            
            try? dataController.viewContext.save()
            
            collectionView.deleteItems(at: selectedPicture)
            
            removePictureButton.isHidden = true
            newCollectionButton.isHidden = false
            
        }
        
        setupFetchedResultController()
        
        performUIUpdatesOnMain {
            self.collectionView.reloadData()
        }
    }
    
    //delete all photos
    
    func deletePhotos() {
        for photo in (photoFetchedResultsController!.fetchedObjects)! {
            dataController.viewContext.delete(photo)
        }
        try? dataController.viewContext.save()
    }
    
    //new collection photo album
    
    func photoAlbumSearch(){
        
        let _ = FlickrClient.sharedInstance().photoAlbumSearch(pin: pin) { (results, error) in
            
            guard (error == nil) else {
                let alert = UIAlertController(title: nil, message: "No Network Connection", preferredStyle: .alert)
                alert.addAction(UIAlertAction (title: "OK", style: .default, handler: nil))
                self.present (alert, animated: true, completion: nil)
                return
            }
            let data = results![FlickrClient.JSONResponseKeys.Photos] as! [String: AnyObject]
            let Pages = data[FlickrClient.ParameterKeys.Pages] as! Int
            
            self.pin.totalPages = Int64(Pages)
            
            guard let photoResults = results![FlickrClient.JSONResponseKeys.Photos]?[FlickrClient.JSONResponseKeys.Photo] as? [[String:Any]] else {
                return
            }
            
            let backgroundContext: NSManagedObjectContext! = self.dataController.backgroundContext
            let pinID = self.pin.objectID
            
            backgroundContext.perform {
                
                let backgroundPin = backgroundContext.object(with: pinID) as! Pin
                
                for result in photoResults {
                    
                    let imageURLString = result[FlickrClient.ParameterValues.Extras] as! String
                    
                    let photo = Photo(context: backgroundContext)
                    photo.url = imageURLString
                    photo.pin = backgroundPin
                }
                
                try? backgroundContext.save()
                
                performUIUpdatesOnMain {
                    self.setupFetchedResultController()
                    self.collectionView.reloadData()
                }
            }
        }
    }
}

// MARK: - PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate

extension PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return photoFetchedResultsController.sections?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoFetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let photo = photoFetchedResultsController.object(at: indexPath)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCell
        
        cell.activityIndicator.isHidden = false
        
        if photo.data == nil {
            
            let backgroundContext:NSManagedObjectContext! = dataController?.backgroundContext
            
            let photoID = photo.objectID
            
            dataController.backgroundContext.perform {
                
                let backgroundaPhoto = backgroundContext.object(with: photoID) as! Photo
                
                let _ = FlickrClient.sharedInstance().downloadPhoto(photo.url!) {
                    (image, error) in
                    guard (error == nil) else {
                        print("Error downloading image: \(error!)")
                        return
                    }
                    
                    backgroundaPhoto.data = image!
                    
                    performUIUpdatesOnMain {
                        cell.imageView.image = UIImage(data: image!)
                    }
                    
                    try? self.dataController.viewContext.save()
                }
                
                try? backgroundContext.save()
            }
        } else {
            performUIUpdatesOnMain {
                cell.activityIndicator.isHidden = true
                cell.imageView.image = UIImage(data:photo.data!)
            }
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        removePictureButton.isHidden = false
        newCollectionButton.isHidden = true
        
        collectionView.cellForItem(at: indexPath)?.alpha = 0.5
    }
}

// MARK: - PhotoAlbumViewController: NSFetchedResultsControllerDelegate

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            collectionView.insertItems(at: [newIndexPath!])
            break
        case .delete:
            collectionView.deleteItems(at: [indexPath!])
            break
        case .update:
            collectionView.reloadItems(at: [indexPath!])
        default:
            break
        }
    }
}
