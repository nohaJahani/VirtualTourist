# VirtualTourist

## Title
Virtual Tourist app allows users specify travel locations around the world, and create virtual photo albums for each location. The locations and photo albums will be stored in Core Data.


The app has two view controller:
Travel Locations Map View: Allows the user to drop pins around the world
 Photo Album View: Allows the users to download and edit an album for a location


## Implementation

#### Travel Locations Map
When the app first starts it will open to the map view. Users will be able to zoom and scroll around the map using standard pinch and drag gestures.

The center of the map and the zoom level should be persistent. If the app is turned off, the map should return to the same state when it is turned on again.

Tapping and holding the map drops a new pin. Users can place any number of pins on the map.


When a pin is tapped, the app will navigate to the Photo Album view associated with the pin.

#### Photo Album view
If the user taps a pin that does not yet have a photo album, the app will download Flickr images associated with the latitude and longitude of the pin.

If there are images, then they will be displayed in a collection view.

While the images are downloading, the photo album is in a temporary “downloading” state . The app should determine how many images are available for the pin location, and display  activity indicator for each.
 Tapping New Collection button should empty the photo album and fetch a new set of images. Note that in locations that have a fairly static set of Flickr images, “new” images might overlap with previous collections of images.

Users should be able to remove photos from an album by tapping them. Pictures will flow up to fill the space vacated by the removed photo.

All changes to the photo album should be automatically made persistent.

Tapping the back button should return the user to the Map view.

## Requirements
Xcode 9.2
Swift 4.0

