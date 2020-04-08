//
//  FeedViewController.swift
//  RunItBack
//
//  Created by Tom Zhu on 2020-04-07.
//  Copyright © 2020 Tom Zhu. All rights reserved.
//

import UIKit
import MapKit

struct FeedItem {
    var username: String
    var dateTime: Date
    var location: (lat:Double, lon:Double)
}

class FeedTableViewController: UITableViewController {
    
    @IBOutlet weak var feedTableView: UITableView!
    var feed: [FeedItem] = [FeedItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedItem", for: indexPath) as! FeedItemView
        let currItem = feed[indexPath.row]
        cell.dateTime.text = currItem.
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
