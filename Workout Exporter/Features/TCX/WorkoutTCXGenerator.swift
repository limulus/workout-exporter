//
//  TCXConverter.swift
//  Workout Exporter
//
//  Created by Eric McCarthy on 2/22/25.
//

import HealthKit
import CoreLocation
import Foundation

struct WorkoutTCXGenerator {
    public static let shared = WorkoutTCXGenerator()
    
    private let healthStore = HealthKitManager.shared.healthStore
    
    func convertWorkouts(_ workouts: [HKWorkout]) async throws -> String {
        try await requestAuthorization(for: workouts)
        
        var activitiesXml: [String] = []
        for workout in workouts {
            activitiesXml.append(try await formatWorkout(workout))
        }
        
        let xmlString = """
        <?xml version="1.0" encoding="UTF-8"?>
        <TrainingCenterDatabase
          xmlns="http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2" 
          xmlns:ldn="https://limulus.net/xmlschemas/tcx-extensions/v1"
        >
        <Activities>
          \(activitiesXml.joined(separator: "\n"))
        </Activities>
        </TrainingCenterDatabase>
        """
        
        return xmlString
    }
    
    func requestAuthorization(for workouts: [HKWorkout]) async throws {
        var types: Set<HKObjectType> = []
        for workout in workouts {
            for type in workout.allStatistics.keys {
                types.insert(type)
            }
            if let type = HealthKitManager.shared.distanceType(for: workout) {
                types.insert(type)
            }
        }
        try await HealthKitManager.shared.requestAuthorization(for: types)
    }
    
    private func formatWorkout(_ workout: HKWorkout) async throws -> String {
        let startTime = workout.startDate.formatted(.iso8601)
        let trackpoints = try await collectTrackpoints(from: workout)
        
        return """
          <Activity Sport="\(mapActivityType(workout.workoutActivityType))">
            <Id>\(startTime)</Id>
            <Lap StartTime="\(startTime)">
              <TotalTimeSeconds>\(workout.duration)</TotalTimeSeconds>
              <DistanceMeters>\(workout.totalDistance?.doubleValue(for: .meter()) ?? 0)</DistanceMeters>
              <Calories>\(Int(workout.statistics(for: HKQuantityType(.activeEnergyBurned))?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0))</Calories>
              <Intensity>Active</Intensity>
              <TriggerMethod>Manual</TriggerMethod>
              <Track>
        \(trackpoints.map { $0.toXML() }.joined(separator: "\n"))
              </Track>
            </Lap>
          </Activity>
        """
    }
    
    private func collectTrackpoints(from workout: HKWorkout) async throws -> [TrackPoint] {
        var trackpoints: [TrackPoint] = []
        
        // Process all activities in the workout
        for activity in workout.workoutActivities {
            // Collect heart rate data (time series data)
            for try await result in HealthKitManager.shared.query(quantityType: HKQuantityType(.heartRate), for: activity) {
                let timestamp = result.dateInterval.start
                let heartRate = Int(result.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute())))
                
                let trackpoint = TrackPoint.heartRate(timestamp: timestamp, value: heartRate)
                trackpoints.append(trackpoint)
            }
            
            if let distanceType = HealthKitManager.shared.distanceType(for: workout) {
                let samples = try await HealthKitManager.shared.queryDiscreteQuantitySamples(quantityType: distanceType, for: activity)
                
                for sample in samples {
                    let timestamp = sample.startDate
                    let endTime = sample.endDate
                    let distance = sample.quantity.doubleValue(for: .meter())
                    
                    let trackpoint = TrackPoint.distance(timestamp: timestamp, value: distance, endTime: endTime)
                    trackpoints.append(trackpoint)
                }
            }
        }
        
        // Add location data from workout routes
        let locations = try await HealthKitManager.shared.getWorkoutRoute(for: workout)
        
        print("locations: \(locations)")
        
        for location in locations {
            let trackpoint = TrackPoint.position(timestamp: location.timestamp, location: location)
            trackpoints.append(trackpoint)
        }
        
        // Sort trackpoints by timestamp
        return trackpoints.sorted { $0.timestamp < $1.timestamp }
    }
    
    private func mapActivityType(_ type: HKWorkoutActivityType) -> String {
        switch type {
        case .running, .walking:
            return "Running"
        case .cycling:
            return "Biking"
        default:
            return "Other"
        }
    }
}
