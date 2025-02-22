//
//  WorkoutListView.swift
//  Workout Exporter
//
//  Created by Eric McCarthy on 2/20/25.
//

import SwiftUI
import HealthKit

struct WorkoutChooserView: View {
    @StateObject private var viewModel = WorkoutChooserViewModel()
    var onWorkoutSelected: (HKWorkout) -> Void
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if let error = viewModel.error {
                    VStack {
                        Text(error)
                            .foregroundColor(.red)
                        Button("Retry") {
                            viewModel.refresh()
                        }
                    }
                } else if viewModel.workouts.isEmpty {
                    Text("0 Workouts")
                        .foregroundStyle(.secondary)
                } else {
                    List(viewModel.workouts, id: \.uuid) { workout in
                        Button(action: {
                            onWorkoutSelected(workout)
                        }) {
                            WorkoutViewRow(workout: workout)
                        }
                    }
                    .listStyle(.inset)
                }
            }
            .navigationTitle("Choose a Workout")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct WorkoutViewRow: View {
    let workout: HKWorkout
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(workout.workoutActivityType.name)
            Text(workout.startDate, style: .date)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

extension HKWorkoutActivityType {
    var name: String {
        switch self {
        case .cycling:
            return "Cycling"
        case .hiking:
            return "Hiking"
        case .elliptical:
            return "Elliptical"
        case .rowing:
            return "Rowing"
        case .walking:
            return "Walking"
        case .running:
            return "Running"
        case .traditionalStrengthTraining:
            return "Strength Training"
        case .functionalStrengthTraining:
            return "Functional Strength Training"
        case .highIntensityIntervalTraining:
            return "HIIT"
        case .swimming:
            return "Swimming"
        case .other:
            return "Other"
        default:
            return "Other (\(rawValue))"
        }
    }
}
