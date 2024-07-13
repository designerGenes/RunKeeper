import Foundation
import SwiftData

@Model
final class RunManager {
    @Relationship(deleteRule: .cascade) var runRecords: [RunRecord]
    
    init() {
        self.runRecords = []
        self.initializeRunRecords()
    }
    
    private func initializeRunRecords() {
        let predefinedRuns = RunManager.loadPredefinedRuns()
        print("Loaded \(predefinedRuns.count) predefined runs")
        for run in predefinedRuns {
            if !runRecords.contains(where: { $0.week == run.week && $0.day == run.day }) {
                runRecords.append(RunRecord(week: run.week, day: run.day))
            }
        }
        print("Initialized \(runRecords.count) run records")
    }
    
    static func loadPredefinedRuns() -> [Run] {
        guard let url = Bundle.main.url(forResource: "RunsData", withExtension: "json") else {
            print("Failed to find RunsData.json")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            var decodedRuns = try decoder.decode([Run].self, from: data)
            
            // Assign week and day values
            for (index, run) in decodedRuns.enumerated() {
                let week = (index / 3) + 1
                let day = (index % 3) + 1
                decodedRuns[index] = Run(week: week, day: day, segments: run.segments)
            }
            
            print("Successfully decoded \(decodedRuns.count) runs")
            return decodedRuns
        } catch {
            print("Error decoding RunsData.json: \(error)")
            return []
        }
    }
}
