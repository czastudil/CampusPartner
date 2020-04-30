import CoreLocation

/**
 A `RoutePath` object defines a path that the user can follow to visit a series of waypoints. The object includes information about the route, such as its distance, expected travel time as well as ascend and descend. The object may also include detailed turn-by-turn instructions.
 */
open class RoutePath {
    fileprivate let json: JSONDictionary
    fileprivate let elevation: Bool
    fileprivate let encoded: Bool

    /**
     Initializes a new route path object with the given JSON dictionary representation and first, if the path includes elevation and second, if the path is encoded.

     - paramter json: A JSON dictionary representation of a route path object as returnd by the GraphHopper Routing API.
     - paramter elevation: If `true`, the route points also contain elevation.
     - paramter encoded: If `true`, the route points are encoded.
     */
    internal init(_ json: JSONDictionary, elevation: Bool, encoded: Bool) {
        self.json = json
        self.elevation = elevation
        self.encoded = encoded
    }

    /**
     Initializes a new route path object with the given JSON dictionary representation and the specified options.
     
     - paramter json: A JSON dictionary representation of a route path object as returnd by the GraphHopper Routing API.
     - paramter options: The options object which was used to get the JSON dictionary.
     */
    public convenience init?(json: JSONDictionary, withOptions options: RouteOptions) {
        self.init(json, elevation: options.elevation ?? false, encoded: options.encodePoints)
    }

    /**
     Contains information about the instructions for this route. The last instruction is always the Finish instruction and takes 0ms and 0meter.
     */
    open lazy var instructions: [Instruction] = {
        return (self.json["instructions"] as? [JSONDictionary])?.compactMap({ Instruction(json: $0) }) ?? []
    }()

    /**
     The bounding box of the route.
     */
    open lazy var bbox: BoundingBox? = {
        guard let degrees = self.json["bbox"] as? [CLLocationDegrees] else {
            return nil
        }
        return BoundingBox(degrees: degrees)
    }()

    /**
     This value contains the coordinates of the path.
     */
    open lazy var points: [CLLocation] = {
        return self.processPoints(jsonKey: "points")
    }()

    /**
     This value contains the snapped input points.
     */
    open lazy var snappedWaypoints: [CLLocation] = {
        return self.processPoints(jsonKey: "snapped_waypoints")
    }()

    /**
     The total time of the route, in ms
     */
    open lazy var time: Int = {
        return self.json["time"] as? Int ?? 0
    }()

    /**
     The total distance of the route, in meter
     */
    open lazy var distance: CLLocationDistance = {
        return self.json["distance"] as? CLLocationDistance ?? 0.0
    }()

    /**
     The total ascend (uphill) of the route, in meter
     */
    open lazy var ascend: CLLocationDistance = {
        return self.json["ascend"] as? CLLocationDistance ?? 0.0
    }()

    /**
     The total descend (downhill) of the route, in meter
     */
    open lazy var descend: CLLocationDistance = {
        return self.json["descend"] as? CLLocationDistance ?? 0.0
    }()

    /**
     This zero-based array is only returned if the `optimize` flag of the `RouteOptions` is `true` and contains the used order of the input points specified in the `RouteOptions` constructor i.e. the start, via and end points.
     */
    open lazy var pointsOrder: [Int] = {
        return self.json["points_order"] as? [Int] ?? []
    }()

    /**

     */
    open lazy var transfers: Int = {
        return self.json["transfers"] as? Int ?? 0
    }()

    /**

     */
    open lazy var weight: Double = {
        return self.json["weight"] as? Double ?? Double.infinity
    }()
    
    /**
    * The following three variables were added by Cynthia Zastudil
    */
    open lazy var routeInstructions: [JSONDictionary] = {
        return self.processInstructions(jsonKey: "instructions")
    }()
    
    open lazy var legDistances: [Double] = {
        return self.processLegDistances(insts: routeInstructions)
    }()
    
    open lazy var legTimes: [Double] = {
        return self.processLegTimes(insts: routeInstructions)
    }()
    
    open lazy var instructionIntervals: [[Int]] = {
        return self.processIntervals(insts: routeInstructions)
    }()
}

extension RoutePath {
    fileprivate func processPoints(jsonKey: String) -> [CLLocation] {
        var points = [CLLocation]()
        if encoded {
            if let encodedPoints = json[jsonKey] as? String {
                points = Decoder.decodePoints(encodedPoints, is3D: elevation)
            }
        } else {
            if let geojson = json[jsonKey] as? JSONDictionary {
                if let coordinates = geojson["coordinates"] as? [[CLLocationDegrees]] {
                    points = coordinates.map({
                        return CLLocation(
                            latitude: $0.count >= 2 ? $0[1] : 0.0,
                            longitude: $0.count >= 1 ? $0[0] : 0.0,
                            altitude: $0.count >= 3 ? $0[2] : 0.0)
                    })
                }
            }
        }
        return points
    }
    
    /**
    * The following three functions were added by Cynthia Zastudil
    */
    fileprivate func processInstructions(jsonKey: String) -> [JSONDictionary] {
        if let instructions = json["instructions"] as? [JSONDictionary] {
            return instructions
        } else {
            return [[:]]
        }
    }
    
    // Returns individual distances for each instruction in the route
    fileprivate func processLegDistances(insts: [JSONDictionary]) -> [Double] {
        var distances = [Double]()
        insts.forEach({ inst in
            if let distance = inst["distance"] as? Double {
                distances.append(distance)
            }
        })
        return distances
    }
    
    // Returns individual times for each instruction in the route
    fileprivate func processLegTimes(insts: [JSONDictionary]) -> [Double] {
        var times = [Double]()
        insts.forEach({ inst in
            if let time = inst["time"] as? Double {
                times.append(time)
            }
        })
        return times
    }
    
    // Returns the interval of points from the points array for each instruction
    fileprivate func processIntervals(insts: [JSONDictionary]) -> [[Int]] {
        var intervals = [[Int]]()
        insts.forEach({ inst in
            if let interval = inst["interval"] as? [Int] {
                intervals.append(interval)
            }
        })
        return intervals
    }
}
