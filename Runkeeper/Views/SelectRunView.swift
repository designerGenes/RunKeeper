//
//  SelectRunView.swift
//  Runkeeper
//
//  Created by Jaden Nation on 6/23/24.
//

import SwiftUI
import SwiftData

import SwiftUI
import SwiftData

struct SelectRunView: View {
    @ObservedObject var runManager: RunManager
    @State private var selectedRun: Run?
    @State private var showRunView = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Select a Run")
                    .font(.largeTitle)
                    .padding()
                
                if let nextRun = runManager.getNextRun() {
                    Text("Next Run: Week \(nextRun.week), Day \(nextRun.runNumber)")
                        .font(.headline)
                        .padding()
                } else {
                    Text("All runs completed!")
                        .font(.headline)
                        .padding()
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(groupRunsByWeek().sorted(by: { $0.key < $1.key }), id: \.key) { week, runs in
                            WeekView(week: week, runs: runs, onRunSelected: { run in
                                selectedRun = run
                                showRunView = true
                            })
                        }
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showRunView) {
            if let run = selectedRun {
                RunView(runManager: runManager, run: run)
            }
        }
    }
    
    private func groupRunsByWeek() -> [Int: [Run]] {
        Dictionary(grouping: runManager.runs, by: { $0.week })
    }
}

struct WeekView: View {
    let week: Int
    let runs: [Run]
    let onRunSelected: (Run) -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Week \(week)")
                .font(.title2)
                .fontWeight(.bold)
            
            ForEach(runs.sorted { $0.runNumber < $1.runNumber }) { run in
                RunButton(run: run, onTap: onRunSelected)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct RunButton: View {
    let run: Run
    let onTap: (Run) -> Void
    
    var body: some View {
        Button(action: { onTap(run) }) {
            VStack {
                Text("Day \(run.runNumber)")
                    .font(.headline)
                
                if run.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .frame(width: 80, height: 80)
            .background(run.isCompleted ? Color.green.opacity(0.2) : Color.blue.opacity(0.2))
            .cornerRadius(10)
        }
    }
}
