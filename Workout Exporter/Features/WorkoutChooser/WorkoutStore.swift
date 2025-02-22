//
//  HealthKitManager.swift
//  Workout Exporter
//
//  Created by Eric McCarthy on 2/15/25.
//

import HealthKit
import CoreLocation

class WorkoutStore {
    private let healthStore = HealthKitManager.shared.healthStore
    
    func fetchWorkouts() async throws -> [HKWorkout] {
        let workoutQuery = HKSampleQueryDescriptor(
            predicates: [.workout()],
            sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)],
            limit: 100
        )

        let workouts = try await workoutQuery.result(for: healthStore)
        return workouts
    }
}

