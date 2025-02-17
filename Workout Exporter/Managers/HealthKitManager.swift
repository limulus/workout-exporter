//
//  HealthKitManager.swift
//  Workout Exporter
//
//  Created by Eric McCarthy on 2/15/25.
//


import HealthKit
import CoreLocation

class HealthKitManager {
    static let shared = HealthKitManager()
    
    let healthStore = HKHealthStore()
    
    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitManagerError.deviceNotCapable
        }
        
        // Define the types you want to read:
        let workoutType = HKObjectType.workoutType()
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let workoutRouteType = HKSeriesType.workoutRoute() // For location data
        
        let typesToRead: Set<HKObjectType> = [workoutType, heartRateType, workoutRouteType]
        
        try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
    }
    
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

enum HealthKitManagerError: Error {
    case deviceNotCapable
}
