//
//  ExportStoreViewModel.swift
//  Workout Exporter
//
//  Created by Eric McCarthy on 2/16/25.
//

import SwiftUI

@MainActor
class ExportListViewModel: ObservableObject {
    @Published private(set) var exports: [Export] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: String?
    
    private let exportStore = ExportStore()
    
    init() {
        Task {
            await loadExports()
        }
    }
    
    func loadExports() async {
        isLoading = true
        error = nil
        
        do {
            exports = try exportStore.fetchExports()
        } catch {
            self.error = "Failed to load exports: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func refresh() {
        Task {
            await loadExports()
        }
    }
    
    func deleteExport(at indexSet: IndexSet) {
        // TODO: Implement delete functionality in ExportStore
    }
}
