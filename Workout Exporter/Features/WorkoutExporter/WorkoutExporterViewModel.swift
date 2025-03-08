//
//  WorkoutExporterViewModel.swift
//  Workout Exporter
//
//  Created by Eric McCarthy on 2/21/25.
//

import Foundation
import HealthKit

class WorkoutExporterViewModel: ObservableObject {
    @MainActor @Published var selectedWorkout: HKWorkout?
    
    func processSelectedWorkout() async throws {
        guard let workout = await selectedWorkout else {
            return
        }
        
        try ExportStore.shared.saveExport(try await .fromHealthKitWorkouts([workout]))
        
        await MainActor.run {
            self.selectedWorkout = nil
        }
    }
}
