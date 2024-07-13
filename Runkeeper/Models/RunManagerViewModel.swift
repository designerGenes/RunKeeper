import Foundation
import SwiftData

@MainActor
class RunManagerViewModel: ObservableObject {
    @Published var runManager: RunManager
    private var modelContext: ModelContext
    private let predefinedRuns: [Run]
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.predefinedRuns = RunManager.loadPredefinedRuns()
        print("Loaded \(self.predefinedRuns.count) predefined runs in ViewModel")
        
        do {
            let descriptor = FetchDescriptor<RunManager>()
            let existingManagers = try modelContext.fetch(descriptor)
            if let existingManager = existingManagers.first {
                self.runManager = existingManager
                print("Using existing RunManager with \(existingManager.runRecords.count) run records")
            } else {
                let newManager = RunManager()
                modelContext.insert(newManager)
                self.runManager = newManager
                print("Created new RunManager with \(newManager.runRecords.count) run records")
            }
            
            // Ensure all predefined runs have a corresponding RunRecord
            for run in predefinedRuns {
                if !self.runManager.runRecords.contains(where: { $0.week == run.week && $0.day == run.day }) {
                    let newRecord = RunRecord(week: run.week, day: run.day)
                    self.runManager.runRecords.append(newRecord)
                }
            }
            try modelContext.save()
            print("After initialization, RunManager has \(self.runManager.runRecords.count) run records")
        } catch {
            print("Failed to fetch or create RunManager: \(error)")
            self.runManager = RunManager()
            print("Created fallback RunManager with \(self.runManager.runRecords.count) run records")
        }
    }
    
    func markRunAsCompleted(_ runRecord: RunRecord) {
        runRecord.completedDate = Date()
        try? modelContext.save()
    }
    
    func markRunAsIncomplete(_ runRecord: RunRecord) {
        runRecord.completedDate = nil
        try? modelContext.save()
    }
    
    func getNextRun() -> RunRecord? {
        return runManager.runRecords
            .sorted { ($0.week * 10 + $0.day) < ($1.week * 10 + $1.day) }
            .first { $0.completedDate == nil }
    }
    
    func getPredefinedRun(for runRecord: RunRecord) -> Run? {
        return predefinedRuns.first { $0.week == runRecord.week && $0.day == runRecord.day }
    }
}
