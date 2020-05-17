//
//  Driver.swift
//  Swift Synth
//
//  Created by Brian Thompson on 5/12/20.
//

import AVFoundation

class Driver {
    var minFreq = 1000
    var maxFreq = 8000
    var height = 100
    var width: Int!
    var imageProcessor = ImageProcessing()
    
    init() {
        Synth.shared.setWaveformTo(Oscillator.sine)
        setPlaybackStateTo(true)
    }

    public func processImage(image: CGImage) -> CGImage! {
        return self.imageProcessor.convertToGray(cgImage: image)
    }

    private func setPlaybackStateTo(_ state: Bool) {
        Synth.shared.volume = state ? 1.0 : 0
    }
}
