//
//  Segment.swift
//  Runkeeper
//
//  Created by Jaden Nation on 6/23/24.
//

import Foundation
import SwiftData


enum SegmentType: String, Codable {
    case run
    case walk
}

struct Segment: Codable {
    var type: SegmentType
    var duration: TimeInterval
}
