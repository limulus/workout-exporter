//
//  WorkoutChooserViewModel.swift
//  Workout Exporter
//
//  Created by Eric McCarthy on 2/20/25.
//

import HealthKit

@MainActor
class WorkoutChooserViewModel: ObservableObject {
    @Published private(set) var workouts: [HKWorkout] = []
    @Published private(set)var error: String?
    @Published private(set) var isLoading = false

    init() {
        Task {
            await loadWorkouts()
        }
    }
    
    func loadWorkouts() async {
        isLoading = true
        error = nil
        
        do {
            try await HealthKitManager.shared.requestAuthorization()
            let workouts = try await HealthKitManager.shared.fetchWorkouts()
            self.workouts = workouts
        } catch {
            self.error = "Failed to load workouts: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func refresh() {
        Task {
            await loadWorkouts()
        }
    }
}

