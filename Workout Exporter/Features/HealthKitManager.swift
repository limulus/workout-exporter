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
    
    func requestAuthorization(for types: Set<HKObjectType>) async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitManagerError.deviceNotCapable
        }
        
        try await healthStore.requestAuthorization(toShare: [], read: types)
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
    
    func queryDiscreteQuantitySamples(quantityType: HKQuantityType, for activity: HKWorkoutActivity) async throws -> [HKQuantitySample] {
        let predicate = HKQuery.predicateForSamples(
            withStart: activity.startDate,
            end: activity.endDate,
            options: .strictStartDate
        )
        
        let queryDescriptor = HKSampleQueryDescriptor(
            predicates: [.quantitySample(type: quantityType, predicate: predicate)],
            sortDescriptors: [SortDescriptor(\.startDate, order: .forward)]
        )
        
        return try await queryDescriptor.result(for: healthStore)
    }
    
    func getWorkoutRoute(for workout: HKWorkout) async throws -> [CLLocation] {
        let workoutPredicate = HKQuery.predicateForObjects(from: workout)
        let routeType = HKSeriesType.workoutRoute()
        let routeQuery = HKSampleQueryDescriptor(
            predicates: [.sample(type: routeType, predicate: workoutPredicate)],
            sortDescriptors: [SortDescriptor(\.startDate, order: .forward)]
        )
        
        let samples = try await routeQuery.result(for: healthStore)
        let routes = samples.compactMap { $0 as? HKWorkoutRoute }
        guard let route = routes.first else {
            return []
        }
        
        var allLocations = [CLLocation]()
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKWorkoutRouteQuery(route: route) { query, locations, done, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                if let locations = locations, !locations.isEmpty {
                    allLocations.append(contentsOf: locations)
                }
                
                if done {
                    continuation.resume(returning: allLocations)
                }
            }
            
            healthStore.execute(query)
        }
    }
    
    func distanceType(for workout: HKWorkout) -> HKQuantityType? {
        switch workout.workoutActivityType {
        case .running, .walking, .hiking, .trackAndField:
            return HKQuantityType(.distanceWalkingRunning)
        case .cycling, .handCycling:
            return HKQuantityType(.distanceCycling)
        case .swimming:
            return HKQuantityType(.distanceSwimming)
        case .wheelchairRunPace, .wheelchairWalkPace:
            return HKQuantityType(.distanceWheelchair)
        case .rowing:
            return HKQuantityType(.distanceRowing)
        case .paddleSports:
            return HKQuantityType(.distancePaddleSports)
        case .snowSports, .downhillSkiing, .snowboarding:
            return HKQuantityType(.distanceDownhillSnowSports)
        case .crossCountrySkiing:
            return HKQuantityType(.distanceCrossCountrySkiing)
        default:
            return nil
        }
    }
    
    // TK
    func extraTypesToConsider(for workout: HKWorkout) ->
    Set<HKObjectType> {
        var types: Set<HKObjectType> = []

        switch workout.workoutActivityType {
        case .running, .walking, .hiking, .trackAndField:
            types.insert(HKQuantityType(.stepCount))
            types.insert(HKQuantityType(.runningSpeed))
            types.insert(HKQuantityType(.runningPower))
            types.insert(HKQuantityType(.runningStrideLength))
            types.insert(HKQuantityType(.runningVerticalOscillation))
            types.insert(HKQuantityType(.runningGroundContactTime))

        case .cycling, .handCycling:
            types.insert(HKQuantityType(.cyclingCadence))
            types.insert(HKQuantityType(.cyclingPower))
            types.insert(HKQuantityType(.cyclingSpeed))

        case .swimming:
            types.insert(HKQuantityType(.swimmingStrokeCount))

        case .wheelchairRunPace, .wheelchairWalkPace:
            types.insert(HKQuantityType(.pushCount))

        case .traditionalStrengthTraining, .functionalStrengthTraining, .coreTraining:
            types.insert(HKQuantityType(.appleExerciseTime))

        case .mixedCardio, .highIntensityIntervalTraining, .jumpRope, .stairClimbing:
            types.insert(HKQuantityType(.stepCount))
            types.insert(HKQuantityType(.flightsClimbed))
        
        default: break
        }

        return types
    }

}

enum HealthKitManagerError: Error {
    case deviceNotCapable
}
