//
//  SoundManager.swift
//  Lace
//
//  Created by Jaden Nation on 7/14/24.
//

import Foundation
import AVFoundation

class SoundManager {
    static func playChimeSound() {
        if let soundURL = Bundle.main.url(forResource: "chime", withExtension: "wav") {
            var soundID: SystemSoundID = 0
            AudioServicesCreateSystemSoundID(soundURL as CFURL, &soundID)
            AudioServicesPlaySystemSound(soundID)
        }
    }
}

