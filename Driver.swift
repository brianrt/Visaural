//
//  Driver.swift
//  Swift Synth
//
//  Created by Brian Thompson on 5/12/20.
//

import AVFoundation

class Driver {
    let numNodes = 10//Number of source nodes to attach to audio engine
    let height = 50 //Must be a multiple of numNodes
    
    var imageProcessor: ImageProcessor!
    var soundProcessor: SoundProcessor!
    var synth: Synth!
    
    init(framesPerSecond: Float) {
        imageProcessor = ImageProcessor(height: height)
        soundProcessor = SoundProcessor(yRes: height, framesPerSecond: framesPerSecond)
        let frequencies = soundProcessor.frequencies
        synth = Synth(frequencies: frequencies, numNodes: numNodes)
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
