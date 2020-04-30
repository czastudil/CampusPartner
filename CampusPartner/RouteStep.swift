//
//  RouteStep.swift
//  CampusPartner
//
//  Created by Cindy Zastudil on 4/7/20.
//  Copyright © 2020 Cindy Zastudil. All rights reserved.
//
import Foundation
import CoreLocation

struct RouteStep {
    let instruction: String?
    let distance: Int?
    let timeMin: Double?
    let timeSec: Double?
    //let startCoord: CLLocationCoordinate2D?
    //let endCoord: CLLocationCoordinate2D?
    let interval: [CLLocationCoordinate2D]?
}
