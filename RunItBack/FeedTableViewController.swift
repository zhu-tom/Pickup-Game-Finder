//
//  FeedViewController.swift
//  RunItBack
//
//  Created by Tom Zhu on 2020-04-07.
//  Copyright © 2020 Tom Zhu. All rights reserved.
//

import UIKit
import Foundation
import MapKit
import CoreLocation

struct FeedItem {
    var id: Int = Int()
    var title: String = String()
    var notes: String = String()
    var players: [Any] = [Any]()
    var dateTime: Date = Date()
    var location: (lat:Double, lon:Double) = (Double(), Double())
}

class FeedTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var feedTableView: UITableView!
    var feed: [FeedItem] = [FeedItem]()
    let locationManager = CLLocationManager()
    let distFormatter = MKDistanceFormatter()
    let dateFormatter = DateFormatter()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        distFormatter.units = MKDistanceFormatter.Units.metric
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        // Do any additional setup after loading the view.
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        downloadData()
        
    }
    
    func downloadData() {
        let session = URLSession(configuration: .default)
        let url = URL(string: "http://localhost/Apps/RunItBack/getPosts.php")!
        let task = session.dataTask(with: url) {(data,response,error) in
            if error != nil {
                print("Data retrieval failed")
            } else {
                self.parseJSON(data!)
            }
        }
        task.resume()
    }
    
    func parseJSON(_ data: Data) {
        do {
            let arr = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSArray
            for i in 0..<arr.count {
                let el = arr[i] as! NSDictionary
                if let id = el["id"] as? String, let lat = el["loc_lat"] as? String, let lon = el["loc_lon"] as? String, let title = el["title"] as? String, let notes = el["notes"] as? String, var dateTime = el["dateTime"], let players = el["players"] {
                    
                    dateTime = dateFormatter.date(from: dateTime as! String)!
                    
                    let item = FeedItem(id: Int(id)!, title: title, notes: notes, players: players as! [Any], dateTime: dateTime as! Date, location: (lat: Double(lat)!, lon: Double(lon)!))
                    self.feed.append(item)
                }
            }
            DispatchQueue.main.async {
                self.feedTableView.reloadData()
            }
        }
        catch let error as NSError {
            print(error)
        }
    }
 
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feed.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(#function)
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedItem", for: indexPath) as! FeedItemView
        let currItem = feed[indexPath.row]
        
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.short
        dateFormatter.doesRelativeDateFormatting = true
        dateFormatter.timeZone = TimeZone.current
        cell.dateTime.text = dateFormatter.string(from: currItem.dateTime)

        let locationCoord = CLLocationCoordinate2D(latitude: currItem.location.lat, longitude: currItem.location.lon)
        let locationCL = CLLocation(latitude: currItem.location.lat, longitude: currItem.location.lon)
        //cell.locationMap.setCenter(locationCoord, animated: false)
        cell.locationMap.setRegion(MKCoordinateRegion(center: locationCoord, latitudinalMeters: CLLocationDistance(exactly: 2500)!, longitudinalMeters: CLLocationDistance(exactly: 2500)!), animated: false)
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = locationCoord
//        cell.locationMap.addAnnotation(annotation)
        CLGeocoder().reverseGeocodeLocation(locationCL, completionHandler: {(placemarks, error) -> Void in
            
            if let placemark = placemarks?[0] {
                cell.locationMap.addAnnotation(MKPlacemark(placemark: placemark))
                if CLLocationManager.locationServicesEnabled(), let loc = self.locationManager.location {
                    cell.locationLabel.text = self.distFormatter.string(fromDistance: locationCL.distance(from: loc))
                } else {
                    cell.locationLabel.text = "Enable Location Services"
                }
                
            }
            
        })
        cell.title.text = currItem.title
        cell.feedItem = currItem
        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.destination is FeedDetailsViewController && sender is FeedItemView {
            let vc = segue.destination as! FeedDetailsViewController
            vc.feedItem = (sender as! FeedItemView).feedItem
        }
        
        
    }

}
