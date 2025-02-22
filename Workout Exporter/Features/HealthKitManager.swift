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
            HKSeriesType.workoutRoute(),
        ])
    }
}

enum HealthKitManagerError: Error {
    case deviceNotCapable
}
