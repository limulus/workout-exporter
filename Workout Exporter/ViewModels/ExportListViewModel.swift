import SwiftUI
import HealthKit

class ExportListViewModel: ObservableObject {
    @Published private(set) var exports: [ExportItem] = []
    
    func addNewExport(for workout: HKWorkout) {
        let newExport = ExportItem(workout: workout, status: .inProgress, progress: 0.0)
        exports.insert(newExport, at: 0)
        
        Task {
            do {
                // Simulate progress (in real app, you'd update based on actual progress)
                for progress in stride(from: 0.0, through: 1.0, by: 0.1) {
                    try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second delay
                    await updateProgress(for: workout, progress: progress)
                }
                
                // Perform actual export
                let _ = try await ExportManager.shared.exportWorkout(workout)
                
                // Update status to completed
                await updateStatus(for: workout, status: .completed)
            } catch {
                await updateStatus(for: workout, status: .failed)
            }
        }
    }
    
    @MainActor
    private func updateProgress(for workout: HKWorkout, progress: Double) {
        if let index = exports.firstIndex(where: { $0.workout.uuid == workout.uuid }) {
            exports[index] = ExportItem(
                workout: workout,
                status: .inProgress,
                progress: progress
            )
        }
    }
    
    @MainActor
    private func updateStatus(for workout: HKWorkout, status: ExportStatus) {
        if let index = exports.firstIndex(where: { $0.workout.uuid == workout.uuid }) {
            exports[index] = ExportItem(
                workout: workout,
                status: status,
                progress: status == .completed ? nil : exports[index].progress
            )
        }
    }
}