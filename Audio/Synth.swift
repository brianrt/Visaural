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
    
    init(frequencies: [Float], numNodes: Int) {
        times = [Float](repeating: 0, count: numNodes)
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
        
        let numFrequencies = frequencies.count
        let frequenciesPerNode = numFrequencies / numNodes
        var f_index = 0
        for n_index in 0..<numNodes {
            let range = f_index..<f_index + frequenciesPerNode
            let nodeFrequencies = Array(frequencies[range])
            let sourceNode = createSourceNode(range: range, frequencies: nodeFrequencies, index: n_index)
            audioEngine.attach(sourceNode)
            audioEngine.connect(sourceNode, to: mainMixer, format: inputFormat)
            f_index += frequenciesPerNode
        }
        
        audioEngine.connect(mainMixer, to: outputNode, format: nil)
        mainMixer.outputVolume = 0
        
        do {
            try audioEngine.start()
        } catch {
            print("Could not start engine: \(error.localizedDescription)")
        }
    }

    deinit {
        audioEngine.stop()
    }
    
    private func createSourceNode(range: Range<Int>, frequencies: [Float], index: Int) -> AVAudioSourceNode {
        return AVAudioSourceNode { _, _, frameCount, audioBufferList in
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)

            for frame in 0..<Int(frameCount) {
                var time = self.times[index]
                let sampleVal = self.signal(time, frequencies, range)
                time += self.deltaTime
                if time > 115 {
                    time = 0.0
                }
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
