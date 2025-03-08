//
//  TrackPoint.swift
//  Workout Exporter
//
//  Created by Eric McCarthy on 3/8/25.
//

import Foundation
import CoreLocation

let dateTimeFormatter = Date.ISO8601FormatStyle.iso8601.year().month().day().time(includingFractionalSeconds: true)

enum TrackPoint {
    case heartRate(timestamp: Date, value: Int)
    case distance(timestamp: Date, value: Double)
    case position(timestamp: Date, coordinate: CLLocationCoordinate2D)
    
    var timestamp: Date {
        switch self {
        case .heartRate(let timestamp, _),
             .distance(let timestamp, _),
             .position(let timestamp, _):
            return timestamp
        }
    }
    
    func toXML() -> String {
        var result = """
            <Trackpoint>
                <Time>\(timestamp.formatted(dateTimeFormatter))</Time>
        """
        
        switch self {
        case .heartRate(_, let value):
            result += """
                
                <HeartRateBpm>
                    <Value>\(value)</Value>
                </HeartRateBpm>
            """
        case .distance(_, let value):
            result += """
                
                <DistanceMeters>\(value)</DistanceMeters>
            """
        case .position(_, let coordinate):
            result += """
                
                <Position>
                    <LatitudeDegrees>\(coordinate.latitude)</LatitudeDegrees>
                    <LongitudeDegrees>\(coordinate.longitude)</LongitudeDegrees>
                </Position>
            """
        }
        
        result += """
            
            </Trackpoint>
        """
        
        return result
    }
}