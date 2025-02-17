import Foundation
import HealthKit

class ExportManager {
    static let shared = ExportManager()
    
    private let fileManager = FileManager.default
    private let exportDirectory: URL
    
    private init() {
        // Get the Documents directory
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        exportDirectory = docs.appendingPathComponent("exports", isDirectory: true)
        
        // Create exports directory if it doesn't exist
        try? fileManager.createDirectory(at: exportDirectory, withIntermediateDirectories: true)
    }
    
    func exportWorkout(_ workout: HKWorkout) async throws -> URL {
        // Create a unique filename based on date and UUID
        let fileName = "\(workout.startDate.ISO8601Format())_\(workout.uuid.uuidString).xml"
        let fileURL = exportDirectory.appendingPathComponent(fileName)
        
        // Get energy burned using the appropriate API
        let energyBurned: HKQuantity?
        if #available(iOS 18.0, *) {
            let energyType = HKQuantityType(.activeEnergyBurned)
            let statistics = workout.statistics(for: energyType)
            energyBurned = statistics?.sumQuantity()
        } else {
            energyBurned = workout.totalEnergyBurned
        }
        
        // Create XML content
        let xmlContent = """
        <?xml version="1.0" encoding="UTF-8"?>
        <workout>
            <type>\(workout.workoutActivityType.name)</type>
            <startDate>\(workout.startDate.ISO8601Format())</startDate>
            <endDate>\(workout.endDate.ISO8601Format())</endDate>
            <duration>\(workout.duration)</duration>
            <totalEnergyBurned>\(energyBurned?.doubleValue(for: .kilocalorie()) ?? 0)</totalEnergyBurned>
            <totalDistance>\(workout.totalDistance?.doubleValue(for: .meter()) ?? 0)</totalDistance>
        </workout>
        """
        
        // Write to file
        try xmlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        return fileURL
    }
}
