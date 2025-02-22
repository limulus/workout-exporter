//
//  ExportListView.swift
//  Workout Exporter
//
//  Created by Eric McCarthy on 2/16/25.
//

import SwiftUI

struct ExportListView: View {
    @StateObject private var viewModel = ExportListViewModel()
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if let error = viewModel.error {
                VStack {
                    Text(error)
                        .foregroundColor(.red)
                    Button("Retry") {
                        viewModel.refresh()
                    }
                }
            } else if viewModel.exports.isEmpty {
                Text("No Exports")
                    .foregroundStyle(.secondary)
            } else {
                List {
                    ForEach(viewModel.exports) { export in
                        ExportRowView(export: export)
                    }
                }
            }
        }
    }
}

struct ExportRowView: View {
    let export: Export
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(export.name)
            Text(export.date, style: .date)
                .foregroundStyle(.secondary)
        }
    }
}
