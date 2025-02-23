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
    
    func convertWorkouts(_ workouts: [HKWorkout]) async -> String {
        let activities = workouts.flatMap(\.workoutActivities)
        
        let xmlString = """
        <?xml version="1.0" encoding="UTF-8"?>
        <TrainingCenterDatabase xmlns="http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2">
            <Activities>
                \(activities.map({ formatActivity($0) }).joined(separator: "\n"))
            </Activities>
        </TrainingCenterDatabase>
        """
        
        return xmlString
    }
    
    private func formatActivity(_ activity: HKWorkoutActivity) -> String {
        return """
        <Activity Sport="\(mapActivityType(activity.workoutConfiguration.activityType))">
            <Id>\(activity.uuid)</Id>
            <!-- TK -->
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
}
