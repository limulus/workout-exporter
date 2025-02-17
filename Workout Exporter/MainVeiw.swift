//
//  MainVeiw.swift
//  Workout Exporter
//
//  Created by Eric McCarthy on 2/16/25.
//

import SwiftUI

struct MainView: View {
    @State private var showingWorkoutChooser = false
    @State private var hasExports = false
    
    var body: some View {
        VStack {
            if hasExports {
                Button("Export Workout...") {
                    showingWorkoutChooser = true
                }
                .padding()
                
                ExportListView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Spacer()
                Button("Export Workout...") {
                    showingWorkoutChooser = true
                }
                Spacer()
            }
        }
        .padding()
        .sheet(isPresented: $showingWorkoutChooser) {
            WorkoutChooser { selectedWorkout in
                hasExports = true
                // TODO: Reference the ExportListView to add new export
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
