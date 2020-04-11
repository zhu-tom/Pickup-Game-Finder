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

class FeedItem {
    var id: Int = Int()
    var title: String = String()
    var notes: String = String()
    var players: [Any] = [Any]()
    var dateTime: Date = Date()
    var locationCL: CLLocation = CLLocation()
    var locationCoord: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var region: MKCoordinateRegion = MKCoordinateRegion()
    var annotation: MKPlacemark? = nil
    
    init() {
        
    }
    
    init(id: Int, title: String, notes: String, players: [Any], dateTime: Date, location: (lat: Double, lon: Double)) {
        self.id = id
        self.title = title
        self.notes = notes
        self.players = players
        self.dateTime = dateTime
        self.locationCoord = CLLocationCoordinate2D(latitude: location.lat, longitude: location.lon)
        self.locationCL = CLLocation(latitude: location.lat, longitude: location.lon)
        self.region = MKCoordinateRegion(center: self.locationCoord, latitudinalMeters: CLLocationDistance(exactly: 250)!, longitudinalMeters: CLLocationDistance(exactly: 250)!)
        CLGeocoder().reverseGeocodeLocation(self.locationCL, completionHandler: {(placemarks, error) -> Void in
            
            if let placemark = placemarks?[0] {
                self.annotation = MKPlacemark(placemark: placemark)
            }
            
        })
    }
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

        cell.locationMap.setRegion(currItem.region, animated: false)

        if let annotation = currItem.annotation {
            cell.locationMap.addAnnotation(annotation)
        }
        
        cell.locationLabel.text = getDistance(to: currItem.locationCL)
        
        cell.title.text = currItem.title
        cell.feedItem = currItem
        return cell
    }
    
    func getDistance(to locationCL: CLLocation) -> String {
        if CLLocationManager.locationServicesEnabled(), let loc = self.locationManager.location {
            return self.distFormatter.string(fromDistance: locationCL.distance(from: loc))
        } else {
            return "Enable Location Services"
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.destination is FeedDetailsViewController && sender is FeedItemView {
            let vc = segue.destination as! FeedDetailsViewController
            let senderItem = (sender as! FeedItemView).feedItem
            vc.feedItem = senderItem
            let view = vc.view as! FeedDetailsView
            view.titleLabel.text = senderItem.title
            view.notesLabel.text = senderItem.notes
            view.distanceLabel.text = getDistance(to: senderItem.locationCL)
            view.dateLabel.text = dateFormatter.string(from: senderItem.dateTime)
            //view.locationMap.setRegion(MKCoordinateRegion(center: (sender as! FeedItemView).locationMap.centerCoordinate, latitudinalMeters: 2500, longitudinalMeters: 2500), animated: false)
            view.locationMap.setRegion(senderItem.region, animated: false)
            if let annotation = senderItem.annotation {
                view.locationMap.addAnnotation(annotation)
            }
        }
        
        
    }

}
