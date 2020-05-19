//
//  Driver.swift
//  Swift Synth
//
//  Created by Brian Thompson on 5/12/20.
//

import AVFoundation

class Driver {
    let height = 35
    
    var imageProcessor: ImageProcessor!
    var soundProcessor: SoundProcessor!
    var synth: Synth!
    
    init(framesPerSecond: Float) {
        imageProcessor = ImageProcessor(height: height)
        soundProcessor = SoundProcessor(yRes: height, framesPerSecond: framesPerSecond)
        let frequencies = soundProcessor.frequencies
        synth = Synth(frequencies: frequencies)
        setPlaybackStateTo(true)
    }

    public func processImage(image: CGImage) -> CGImage! {
        let transformedImage = imageProcessor.convertToGray(cgImage: image)
        if transformedImage != nil {
            soundProcessor.generateSound(image: transformedImage!)
        }
        return transformedImage
    }

    private func setPlaybackStateTo(_ state: Bool) {
        synth.volume = state ? 1.0 : 0
    }
}
