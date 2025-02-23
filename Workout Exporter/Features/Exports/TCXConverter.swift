//
//  TCXConverter.swift
//  Workout Exporter
//
//  Created by Eric McCarthy on 2/22/25.
//

import HealthKit

struct TCXConverter {
    public static let shared = TCXConverter()
    
    private let healthStore = HealthKitManager.shared.healthStore
    
    func convertWorkouts(_ workouts: [HKWorkout]) async throws -> String {
        var activitiesXml: [String] = []
        for activity in workouts.flatMap(\.workoutActivities) {
            activitiesXml.append(try await formatActivity(activity))
        }
        
        let xmlString = """
        <?xml version="1.0" encoding="UTF-8"?>
        <TrainingCenterDatabase xmlns="http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2">
            <Activities>
                \(activitiesXml.joined(separator: "\n"))
            </Activities>
        </TrainingCenterDatabase>
        """
        
        return xmlString
    }
    
    private func formatActivity(_ activity: HKWorkoutActivity) async throws -> String {
        let startTime = activity.startDate.formatted(.iso8601)
        
        return """
        <Activity Sport="\(mapActivityType(activity.workoutConfiguration.activityType))">
            <Id>\(startTime)</Id>
            <Lap StartTime="\(startTime)">
                <TotalTimeSeconds>\(activity.duration)</TotalTimeSeconds>
                <DistanceMeters>\(formatDistance(for: activity))</DistanceMeters>
                <Calories>\(formatActiveCalories(for: activity))</Calories>
                <Intensity>Active</Intensity>
                <TriggerMethod>Manual</TriggerMethod>
                \(try await formatTrackpoints(for: activity))
            </Lap>
        </Activity>
        """
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
    
    private func formatDistance(for activity: HKWorkoutActivity) -> Double {
        let distanceTypes = [
            HKQuantityType(.distanceWalkingRunning),
            HKQuantityType(.distanceCycling),
            HKQuantityType(.distanceSwimming),
            HKQuantityType(.distanceWheelchair),
            HKQuantityType(.distanceRowing),
            HKQuantityType(.distancePaddleSports),
            HKQuantityType(.distanceSkatingSports),
            HKQuantityType(.distanceCrossCountrySkiing),
            HKQuantityType(.distanceDownhillSnowSports),
            HKQuantityType(.sixMinuteWalkTestDistance)
        ]
        
        for type in distanceTypes {
            if let statistics = activity.statistics(for: type) {
                return statistics.sumQuantity()?.doubleValue(for: .meter()) ?? 0
            }
        }
        
        return 0
    }
    
    private func formatActiveCalories(for activity: HKWorkoutActivity) -> UInt16 {
        guard let statistics = activity.statistics(for: HKQuantityType(.activeEnergyBurned)) else { return 0 }
        guard let calories = statistics.sumQuantity()?.doubleValue(for: .largeCalorie()) else { return 0 }
        return UInt16(min(calories, Double(UInt16.max)))
    }
    
    private func formatTrackpoints(for activity: HKWorkoutActivity) async throws -> String {
        var trackpointsXml: [String] = []
        for try await sample in HealthKitManager.shared.query(quantityType: HKQuantityType(.heartRate), for: activity) {
            let heartRate = Int(sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute())))
            trackpointsXml.append("""
                <Trackpoint>
                    <Time>\(sample.dateInterval.start.formatted(.iso8601))</Time>
                    <HeartRateBpm>
                        <Value>\(heartRate)</Value>
                    </HeartRateBpm>
                </Trackpoint>
             """)
        }
        return """
            <Track>
                \(trackpointsXml.joined(separator: "\n"))
            </Track>
        """
    }
}
