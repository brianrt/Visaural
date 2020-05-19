//
//  Synth.swift
//  Swift Synth
//
//  Created by Brian Thompson.
//  Copyright © 2020 Brian Thompson. All rights reserved.
//

import AVFoundation

class Synth {
    public var volume: Float {
        set {
            audioEngine.mainMixerNode.outputVolume = newValue
        }
        get {
            audioEngine.mainMixerNode.outputVolume
        }
    }
    private var audioEngine: AVAudioEngine
    
    private var times: [Float] = [0]
    private let sampleRate: Double
    private let deltaTime: Float // time between samples taken at sampleRate
    private var signal: Signal
    
    init(frequencies: [Float]) {
        times = [Float](repeating: 0, count: frequencies.count)
        audioEngine = AVAudioEngine()
        
        let mainMixer = audioEngine.mainMixerNode
        let outputNode = audioEngine.outputNode
        let format = outputNode.inputFormat(forBus: 0)
        
        sampleRate = format.sampleRate
        deltaTime = 1 / Float(sampleRate)
        
        self.signal = Oscillator.sine
        Oscillator.height = Float(frequencies.count)
        
        let inputFormat = AVAudioFormat(commonFormat: format.commonFormat,
                                        sampleRate: format.sampleRate,
                                        channels: 1,
                                        interleaved: format.isInterleaved)
        
        for i in 0..<frequencies.count {
            let frequency = frequencies[i]
            let sourceNode = createSourceNode(index: i, frequency: frequency)
            audioEngine.attach(sourceNode)
            audioEngine.connect(sourceNode, to: mainMixer, format: inputFormat)
        }
        
        audioEngine.connect(mainMixer, to: outputNode, format: nil)
        mainMixer.outputVolume = 0
        
        do {
            try audioEngine.start()
        } catch {
            print("Could not start engine: \(error.localizedDescription)")
        }
        
    }
    
    private func createSourceNode(index: Int, frequency: Float) -> AVAudioSourceNode {
        return AVAudioSourceNode { _, _, frameCount, audioBufferList in
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)

            for frame in 0..<Int(frameCount) {
                var time = self.times[index]
                let sampleVal = self.signal(time, frequency, index)
                time += self.deltaTime
                time = fmod(time, 1/frequency)
                self.times[index] = time
                
                for buffer in ablPointer {
                    let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
                    buf[frame] = sampleVal
                }
            }
            
            return noErr
        }
    }
    
}
