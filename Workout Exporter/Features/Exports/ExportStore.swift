//
//  ExportStore.swift
//  Workout Exporter
//
//  Created by Eric McCarthy on 2/19/25.
//

import Foundation

struct ExportStore {
    private let fileManager = FileManager.default
    
    func saveExport(export: Export) throws {
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw ExportError.documentsDirectoryNotFound
        }
        
        let exportsDirectory = documentsPath.appendingPathComponent("Exports", isDirectory: true)
        
        if !fileManager.fileExists(atPath: exportsDirectory.path) {
            do {
                try fileManager.createDirectory(at: exportsDirectory,
                                             withIntermediateDirectories: true,
                                             attributes: [FileAttributeKey.protectionKey: FileProtectionType.complete])
            } catch {
                throw ExportError.securityError("Failed to create secure directory: \(error.localizedDescription)")
            }
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HHmmss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let timestamp = dateFormatter.string(from: Date())
        let filename = "export-\(timestamp).json"
        
        let fileURL = exportsDirectory.appendingPathComponent(filename)
        
        try export.save(to: fileURL)
    }
    
    func fetchExports() throws -> [Export] {
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw ExportError.documentsDirectoryNotFound
        }
        
        let exportsDirectory = documentsPath.appendingPathComponent("Exports", isDirectory: true)
        
        // Return empty array if directory doesn't exist yet
        guard fileManager.fileExists(atPath: exportsDirectory.path) else {
            return []
        }
        
        // Get all files in directory
        let fileURLs = try fileManager.contentsOfDirectory(
            at: exportsDirectory,
            includingPropertiesForKeys: nil,
            options: .skipsHiddenFiles
        )
        
        // Sort URLs by filename (newest first) and then load exports
        let exports = try fileURLs
            .filter { $0.pathExtension == "json" }
            .sorted { $0.lastPathComponent > $1.lastPathComponent }
            .compactMap { url -> Export? in
                try Export.load(from: url)
            }
        
        return exports
    }
}

enum ExportError: Error {
    case documentsDirectoryNotFound
    case securityError(String)
}
