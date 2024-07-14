import Foundation
import SwiftData

@MainActor
class RunManagerViewModel: ObservableObject {
    @Published var runManager: RunManager
    private var modelContext: ModelContext
    private var predefinedRuns: [Run]
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.predefinedRuns = RunManager.loadPredefinedRuns()
        
        do {
            let descriptor = FetchDescriptor<RunManager>()
            let existingManagers = try modelContext.fetch(descriptor)
            if let existingManager = existingManagers.first {
                self.runManager = existingManager
            } else {
                let newManager = RunManager()
                modelContext.insert(newManager)
                self.runManager = newManager
            }
        } catch {
            print("Failed to fetch RunManager: \(error)")
            self.runManager = RunManager()
        }
    }
    
    func markRunAsCompleted(_ runRecord: RunRecord) {
        runRecord.completedDate = Date()
        try? modelContext.save()
        objectWillChange.send()
    }
    
    func markRunAsIncomplete(_ runRecord: RunRecord) {
        runRecord.completedDate = nil
        try? modelContext.save()
        objectWillChange.send()
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
