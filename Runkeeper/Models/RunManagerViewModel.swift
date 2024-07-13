import Foundation
import SwiftData

@MainActor
class RunManagerViewModel: ObservableObject {
    @Published var runManager: RunManager
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        
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
    
    func markRunAsCompleted(_ run: Run) {
        if let index = runManager.runs.firstIndex(where: { $0.week == run.week && $0.runNumber == run.runNumber }) {
            runManager.runs[index].completedDate = Date()
            try? modelContext.save()
        }
    }
    
    func markRunAsIncomplete(_ run: Run) {
        if let index = runManager.runs.firstIndex(where: { $0.week == run.week && $0.runNumber == run.runNumber }) {
            runManager.runs[index].completedDate = nil
            try? modelContext.save()
        }
    }
    
    func getNextRun() -> Run? {
        let sortedRuns = runManager.runs.sorted { ($0.week * 10 + $0.runNumber) < ($1.week * 10 + $1.runNumber) }
        return sortedRuns.first { $0.completedDate == nil }
    }
}
