//
//  ContentView.swift
//  BuildBar
//
//  Created by Kobe on 7/26/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var pipelineStore: PipelineStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerView
            
            Divider()
                .padding(.vertical, 8)
            
            pipelineList
            
            Divider()
                .padding(.vertical, 8)
            
            footerView
        }
        .padding()
        .fixedSize()
    }
    
    private var headerView: some View {
        HStack {
            Text("BuildBar")
                .font(.headline)
            
            Spacer()
            
            Image(systemName: pipelineStore.overallStatus.icon)
                .foregroundColor(pipelineStore.overallStatus.color)
                .font(.title2)
        }
    }
    
    private var pipelineList: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(pipelineStore.pipelines) { pipeline in
                PipelineRowView(pipeline: pipeline)
            }
        }
    }
    
    private var footerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Button("Refresh All") {
                // TODO: Implement refresh functionality
            }
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
    }
}

struct PipelineRowView: View {
    let pipeline: Pipeline
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: pipeline.status.icon)
                .foregroundColor(pipeline.status.color)
                .frame(width: 16)
                .fixedSize()
            
            VStack(alignment: .leading, spacing: 2) {
                Text(pipeline.name)
                    .font(.system(size: 13, weight: .medium))
                    .fixedSize(horizontal: true, vertical: false)
                
                Text(pipeline.repository)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: true, vertical: false)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(pipeline.duration)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: true, vertical: false)
                
                Text(formatDate(pipeline.lastRun))
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: true, vertical: false)
            }
            .fixedSize()
        }
        .padding(.vertical, 2)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    ContentView()
        .environmentObject(PipelineStore())
}
