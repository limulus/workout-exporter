//
//  Export.swift
//  Workout Exporter
//
//  Created by Eric McCarthy on 2/16/25.
//

import Foundation

struct Export: Identifiable, Codable {
    let id: UUID
    let name: String
    let status: ExportStatus
    let workoutIds: [UUID]
    let date: Date
    let fileName: String
    let failureReason: String?
    
    init(id: UUID = UUID(), name: String, status: ExportStatus, workoutIds: [UUID], date: Date, fileName: String, failureReason: String? = nil) {
        self.id = id
        self.name = name
        self.status = status
        self.workoutIds = workoutIds
        self.date = date
        self.fileName = fileName
        self.failureReason = failureReason
    }
    
    func updateStatus(status: ExportStatus) -> Export {
        return Export(name: name, status: status, workoutIds: workoutIds, date: date, fileName: fileName, failureReason: failureReason)
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
    
    // Convenience method to load from file
    static func load(from url: URL) throws -> Export {
        let data = try Data(contentsOf: url)
        return try decode(from: data)
    }
    
    // Convenience method to save to file
    func save(to url: URL) throws {
        let data = try encode()
        try data.write(to: url, options: [.atomic, .completeFileProtection])
    }
}

enum ExportStatus: Codable {
    case inProgress
    case completed
    case failed
}
