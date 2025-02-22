//
//  WorkoutExporterView.swift
//  Workout Exporter
//
//  Created by Eric McCarthy on 2/15/25.
//

import SwiftUI

struct WorkoutExporterView: View {
    @State private var showWorkoutChooserSheet = false
    @ObservedObject private var viewModel = WorkoutExporterViewModel()
    
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
                viewModel.handleWorkoutSelection(workout)
                showWorkoutChooserSheet = false
            }
        }
    }
}

#Preview {
    WorkoutExporterView()
}
