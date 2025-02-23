//
//  HealthKitManager.swift
//  Workout Exporter
//
//  Created by Eric McCarthy on 2/22/25.
//

import HealthKit
import CoreLocation

class HealthKitManager {
    public static let shared = HealthKitManager()
    
    public var healthStore = HKHealthStore()
    
    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitManagerError.deviceNotCapable
        }
        
        try await healthStore.requestAuthorization(toShare: [], read: [
            HKObjectType.workoutType(),
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
            HKSeriesType.workoutRoute(),
        ])
    }
    
    func query(quantityType: HKQuantityType, for activity: HKWorkoutActivity) -> HKQuantitySeriesSampleQueryDescriptor.Results {
        let predicate = HKSamplePredicate.quantitySample(
            type: quantityType,
            predicate: HKQuery.predicateForSamples(withStart: activity.startDate, end: activity.endDate)
        )
        let seriesDescriptor = HKQuantitySeriesSampleQueryDescriptor(
            predicate: predicate,
            options: .orderByQuantitySampleStartDate
        )
        return seriesDescriptor.results(for: healthStore)
    }
}

enum HealthKitManagerError: Error {
    case deviceNotCapable
}
