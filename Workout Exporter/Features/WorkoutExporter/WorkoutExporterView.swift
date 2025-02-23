//
//  WorkoutExporterView.swift
//  Workout Exporter
//
//  Created by Eric McCarthy on 2/15/25.
//

import SwiftUI

struct WorkoutExporterView: View {
    @ObservedObject private var viewModel = WorkoutExporterViewModel()
    
    @State private var showWorkoutChooserSheet = false
    @State private var showErrorAlert = false
    @State private var error: Error?
    
    var body: some View {
        VStack {
            ExportListView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Spacer()
            Button("Export Workout…") {
                showWorkoutChooserSheet = true
            }.padding()
        }
        .sheet(isPresented: $showWorkoutChooserSheet) {
            WorkoutChooserView { workout in
                Task {
                    do {
                        try await viewModel.handleWorkoutSelection(workout)
                        showWorkoutChooserSheet = false
                    } catch (let err) {
                        self.error = err
                    }
                }
            }
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Text(error?.localizedDescription ?? "An unknown error occurred.")
            Button("OK") {
                showErrorAlert = false
                error = nil
            }
        }
    }
}

#Preview {
    WorkoutExporterView()
}
