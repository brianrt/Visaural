//
//  Oscillator.swift
//  Swift Synth
//
//  Created by Grant Emerson on 7/21/19.
//  Copyright © 2019 Grant Emerson. All rights reserved.
//

import AVFoundation

typealias Signal = (_ frequency: Float, _ time: Float) -> Float

struct Oscillator {
    
    static var amplitude: Float = 1
    static var frequencies: [Float] = [440]
    
    static let sine: Signal = { frequency, time in
        return Oscillator.amplitude * sin(2.0 * Float.pi * frequency * time)
    }
}

class SoundProcessor {
    let minFreq: Float = 1000.0
    let maxFreq: Float = 8000.0
    let numTones = 3
    let contrast: Float = 5.0
    
    var frequencies: [Float] //list of frequencies given height of image
    
    init(yResolution: Int, framesPerSecond: Float) {
        let height: Float = (maxFreq - minFreq) / Float(yResolution)
        let toneDelta: Float = height / Float(numTones)
        
        frequencies = []
        for y in 0..<yResolution {
            let baseFreq = (maxFreq - minFreq) / height * (height - Float(y)) + minFreq
            var toneFreq = baseFreq
            frequencies.append(baseFreq)
            for _ in 0..<numTones - 1 {
                toneFreq += toneDelta
                frequencies.append(toneFreq)
            }
        }
    }
    
    public func generateSound(image: CGImage) {
        
    }
}


