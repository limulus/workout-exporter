//
//  ExportListView.swift
//  Workout Exporter
//
//  Created by Eric McCarthy on 2/16/25.
//

import SwiftUI

struct ExportListView: View {
    @StateObject private var viewModel = ExportListViewModel()
    @StateObject private var exportStore = ExportStore.shared
    
    var body: some View {
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
        } else if exportStore.exports.isEmpty {
            Text("No Exports")
                .foregroundStyle(.secondary)
        } else {
            List {
                ForEach(exportStore.exports) { export in
                    ShareLink(
                        item: try! export.load().data!,
                        preview: SharePreview(
                            export.name,
                            image: "doc.xml"
                        )
                    ) {
                        ExportRowView(export: export)
                    }
                }
            }
        }
    
    }
}

struct ExportRowView: View {
    let export: ExportRef
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(export.name)
        }
    }
}
