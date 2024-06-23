//
//  Run.swift
//  Runkeeper
//
//  Created by Jaden Nation on 6/23/24.
//

import Foundation
import SwiftData

@Model
class Run {
    var week: Int
    var runNumber: Int
    var totalDuration: TimeInterval
    var segments: [Segment]
    var isCompleted: Bool
    
    init(week: Int, runNumber: Int, totalDuration: TimeInterval, segments: [Segment], isCompleted: Bool = false) {
        self.week = week
        self.runNumber = runNumber
        self.totalDuration = totalDuration
        self.segments = segments
        self.isCompleted = isCompleted
    }
}
