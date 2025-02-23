//
//  ExportStore.swift
//  Workout Exporter
//
//  Created by Eric McCarthy on 2/19/25.
//

import Foundation

struct ExportRef: Identifiable {
    let name: String
    let url: URL
    
    public var id: String { url.absoluteString }
    
    init(name: String, url: URL) {
        self.name = name
        self.url = url
    }

    func load() throws -> Export {
        try Export.load(from: url)
    }
}

class ExportStore: ObservableObject {
    static let shared = ExportStore()
    
    @Published var exports: [ExportRef] = []
    
    private let fileManager = FileManager.default
        
    func saveExport(_ export: Export) throws {
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
        
        DispatchQueue.main.async {
            self.exports.insert(ExportRef(name: timestamp, url: fileURL), at: 0)
        }
    }
    
    func fetchExports() throws {
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw ExportError.documentsDirectoryNotFound
        }
        
        let exportsDirectory = documentsPath.appendingPathComponent("Exports", isDirectory: true)
        
        // Return empty array if directory doesn't exist yet
        guard fileManager.fileExists(atPath: exportsDirectory.path) else {
            exports = []
            return
        }
        
        // Get all files in directory
        let fileURLs = try fileManager.contentsOfDirectory(
            at: exportsDirectory,
            includingPropertiesForKeys: nil,
            options: .skipsHiddenFiles
        )
        
        // Sort URLs by filename (newest first) and create ExportRefs
        let newExports = fileURLs
            .filter { $0.pathExtension == "json" }
            .sorted { $0.lastPathComponent > $1.lastPathComponent }
            .map { url in
                let name = url.deletingPathExtension().lastPathComponent
                return ExportRef(name: name, url: url)
            }
        
        DispatchQueue.main.async {
            self.exports = newExports
        }
    }
    
    func deleteExport(_ export: ExportRef) {
        do {
            try fileManager.removeItem(at: export.url)
            
            DispatchQueue.main.async {
                self.exports.removeAll { $0.id == export.id }
            }
        } catch {
            print("Error deleting export: \(error.localizedDescription)")
        }
    }
}

enum ExportError: Error {
    case documentsDirectoryNotFound
    case securityError(String)
}
