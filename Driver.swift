//
//  Driver.swift
//  Swift Synth
//
//  Created by Brian Thompson on 5/12/20.
//

import AVFoundation

class Driver {
    let height = 100
    
    var imageProcessor: ImageProcessor!
    var soundProcessor: SoundProcessor!
    
    init(framesPerSecond: Float) {
        Synth.shared.setWaveformTo(Oscillator.sine)
        setPlaybackStateTo(true)
        imageProcessor = ImageProcessor(height: height)
        soundProcessor = SoundProcessor(yResolution: height, framesPerSecond: framesPerSecond)
    }

    public func processImage(image: CGImage) -> CGImage! {
        let transformedImage = imageProcessor.convertToGray(cgImage: image)
        if transformedImage != nil {
            soundProcessor.generateSound(image: transformedImage!)
        }
        return transformedImage
    }

    private func setPlaybackStateTo(_ state: Bool) {
        Synth.shared.volume = state ? 1.0 : 0
    }
}
