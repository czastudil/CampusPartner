//
//  Route.swift
//  CampusPartner
//
//  Created by Cindy Zastudil on 4/14/20.
//  Copyright © 2020 Cindy Zastudil. All rights reserved.
//

import UIKit
import CoreLocation
import os.log

class Route: NSObject, NSCoding {
    
    // MARK: Properties
    
    var routeTitle: String
    var sourceName: String
    var destName: String
    
    //init(routePath: RoutePath, routeTitle: String) {
    init(routeTitle: String, sourceName: String, destName: String) {
        self.routeTitle = routeTitle
        self.sourceName = sourceName
        self.destName = destName
    }
    
    // MARK: Types
    
    struct PropertyKey {
        static let routeTitle = "routeTitle"
        static let sourceName = "sourceName"
        static let destName = "destName"
    }
    
    // MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(routeTitle, forKey: PropertyKey.routeTitle)
        aCoder.encode(sourceName, forKey: PropertyKey.sourceName)
        aCoder.encode(destName, forKey: PropertyKey.destName)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let title = aDecoder.decodeObject(forKey: PropertyKey.routeTitle) as? String else {
            os_log("Unable to decode the route title for a Route object.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let sourceName = aDecoder.decodeObject(forKey: PropertyKey.sourceName) as? String else {
            os_log("Unable to decode the route title for a Route object.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let destName = aDecoder.decodeObject(forKey: PropertyKey.destName) as? String else {
            os_log("Unable to decode the route title for a Route object.", log: OSLog.default, type: .debug)
            return nil
        }
        self.init(routeTitle: title, sourceName: sourceName, destName: destName)
        
    }
    
    // MARK: Archiving Paths
    
    static var DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static var ArchiveURL = DocumentsDirectory.appendingPathComponent("routes")
}
