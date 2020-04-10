//
//  FeedItemView.swift
//  RunItBack
//
//  Created by Tom Zhu on 2020-04-07.
//  Copyright © 2020 Tom Zhu. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class FeedItemView: UITableViewCell {
    @IBOutlet weak var locationMap: MKMapView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var dateTime: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    var feedItem = FeedItem()
}
