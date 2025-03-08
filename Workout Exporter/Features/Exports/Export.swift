//
//  Export.swift
//  Workout Exporter
//
//  Created by Eric McCarthy on 2/16/25.
//

import Foundation
import HealthKit

struct Export: Identifiable, Codable {
    let id: UUID
    let status: ExportStatus
    let workoutIds: [UUID]
    let date: Date
    let data: String?
    
    init(id: UUID = UUID(), status: ExportStatus, workoutIds: [UUID], date: Date, data: String? = nil) {
        self.id = id
        self.status = status
        self.workoutIds = workoutIds
        self.date = date
        self.data = data
    }
    
    // MARK: - Conversion
    
    static func fromHealthKitWorkouts(_ workouts: [HKWorkout]) async throws -> Export {
        return Export(
            id: UUID(),
            status: .completed,
            workoutIds: workouts.map(\.uuid),
            date: Date(),
            data: try await WorkoutTCXGenerator.shared.convertWorkouts(workouts)
        )
    }
    
    // MARK: - Coding Methods
    
    func encode() throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(self)
    }
    
    static func decode(from data: Data) throws -> Export {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(Export.self, from: data)
    }
    
    static func load(from url: URL) throws -> Export {
        let data = try Data(contentsOf: url)
        return try decode(from: data)
    }
    
    func save(to url: URL) throws {
        let data = try encode()
        try data.write(to: url, options: [.atomic, .completeFileProtection])
    }
}

enum ExportStatus: Codable {
    case failed(reason: String)
    case completed
}
