//
//  WorkoutExporterViewModel.swift
//  Workout Exporter
//
//  Created by Eric McCarthy on 2/21/25.
//

import Foundation
import HealthKit

class WorkoutExporterViewModel: ObservableObject {
    func handleWorkoutSelection(_ workout: HKWorkout) async throws {
        print("Selected workout: \(workout)")
        try ExportStore.shared.saveExport(await .fromHealthKitWorkouts([workout]))
    }
}
