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
    case distance(timestamp: Date, value: Double, endTime: Date?)
    case position(timestamp: Date, location: CLLocation)
    
    var timestamp: Date {
        switch self {
        case .heartRate(let timestamp, _),
             .distance(let timestamp, _, _),
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
        case .distance(_, let value, let endTime):
            result += """
                
                <DistanceMeters>\(value)</DistanceMeters>
            """
            
            if let endTime = endTime {
                result += """
                
                <Extensions>
                    <ldn:EndTime>\(endTime.formatted(dateTimeFormatter))</ldn:EndTime>
                </Extensions>
                """
            }
        case .position(_, let location):
            result += """
                
                <Position>
                    <LatitudeDegrees>\(location.coordinate.latitude)</LatitudeDegrees>
                    <LongitudeDegrees>\(location.coordinate.longitude)</LongitudeDegrees>
                </Position>
                <AltitudeMeters>
                  \(location.altitude)
                </AltitudeMeters>
            """
        }
        
        result += """
            
            </Trackpoint>
        """
        
        return result
    }
}
