//
//  ExportItem.swift
//  Workout Exporter
//
//  Created by Eric McCarthy on 2/16/25.
//

import SwiftUI
import HealthKit

struct ExportItem: Identifiable {
    let id = UUID()
    let workout: HKWorkout
    let status: ExportStatus
    let progress: Double? // nil for completed exports
}

enum ExportStatus {
    case inProgress
    case completed
    case failed
}

struct ExportListView: View {
    @StateObject private var viewModel = ExportListViewModel()
    
    var body: some View {
        List(viewModel.exports) { export in
            ExportItemRow(export: export)
        }
        .listStyle(.plain)
    }
    
    func addNewExport(for workout: HKWorkout) {
        viewModel.addNewExport(for: workout)
    }
}

struct ExportItemRow: View {
    let export: ExportItem
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(export.workout.startDate.formatted(date: .abbreviated, time: .shortened))
                    .font(.headline)
                
                Text(statusText)
                    .font(.subheadline)
                    .foregroundColor(statusColor)
            }
            
            Spacer()
            
            if let progress = export.progress {
                ProgressView(value: progress)
                    .frame(width: 100)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var statusText: String {
        switch export.status {
        case .inProgress: return "Exporting..."
        case .completed: return "Completed"
        case .failed: return "Failed"
        }
    }
    
    private var statusColor: Color {
        switch export.status {
        case .inProgress: return .blue
        case .completed: return .green
        case .failed: return .red
        }
    }
}

struct ExportListView_Previews: PreviewProvider {
    static var previews: some View {
        ExportListView()
    }
}
