//
//  ContentView.swift
//  Workout Exporter
//
//  Created by Eric McCarthy on 2/15/25.
//

import SwiftUI
import HealthKit

struct ExportedWorkoutsView: View {
    @State private var failed: Bool = false
    @State private var errorMessage: String?
    @State private var isShowingWorkoutChooser: Bool = false
    @State private var isShowingProcessing: Bool = false
    @State private var selectedWorkout: HKWorkout?

    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to Workout Exporter!")
                .font(.headline)
            
            Button(action: {
                Task {
                    await chooseWorkout()
                }
            }) {
                Text("Choose Workout")
            }
        }
        .padding()
        .sheet(isPresented: $isShowingWorkoutChooser) {
            WorkoutChooser(onWorkoutSelected: { workout in
                selectedWorkout = workout
                isShowingProcessing = true
            })
        }
        .alert(isPresented: $failed) {
            Alert(
                title: Text("Error"),
                message: Text("An unexpected error occurred: \(String(describing: errorMessage))"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    func chooseWorkout() async {
        print("Showing workout chooser")
        do {
            try await HealthKitManager.shared.requestAuthorization()
            isShowingWorkoutChooser = true
        } catch(let error) {
            self.errorMessage = error.localizedDescription
            self.failed = true
        }
    }
}

#Preview {
    ExportedWorkoutsView()
}
