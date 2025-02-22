//
//  WorkoutExporterViewModel.swift
//  Workout Exporter
//
//  Created by Eric McCarthy on 2/21/25.
//

import Foundation
import HealthKit

class WorkoutExporterViewModel: ObservableObject {
    private let exportStore = ExportStore()
    
    func handleWorkoutSelection(_ workout: HKWorkout) {
        // TODO
        print("Selected workout: \(workout)")
    }
}
