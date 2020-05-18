//
//  Oscillator.swift
//  Swift Synth
//
//  Created by Grant Emerson on 7/21/19.
//  Copyright © 2019 Grant Emerson. All rights reserved.
//

import AVFoundation
import Accelerate

typealias Signal = (_ time: Float) -> Float

struct Oscillator {
    static var rowIndex = 0
    static var all_amplitudes: [[UInt8]] = [[1]]
    static var isUpdating = false
    static var frequencies: [Float] = [440]
    
    static let sine: Signal = { time in
        
        let amplitudes = all_amplitudes[rowIndex]
        let length = amplitudes.count
        
        if length < 2 {
            return 0.0
        }
        var sum: Float = 0.0
        for i in 0..<length {
            let amplitude = Float(amplitudes[i]) / Float(255)
            let frequency = frequencies[i]
            sum = sum + (amplitude * sin(2.0 * Float.pi * frequency * time))
        }
        sum = sum / Float(length)
        return sum
    }
}

class SoundProcessor {
    let minFreq: Float = 500.0
    let maxFreq: Float = 5000.0
    let numTones = 1
    let contrast: Float = 5.0
    var colDuration: Double!
    var framesPerSecond: Double!
    var frequencies: [Float] //list of frequencies given height of image
    
    init(yRes: Int, framesPerSecond: Float) {
        let height: Float = (maxFreq - minFreq) / Float(yRes)
        let toneDelta: Float = height / Float(numTones)
        
        self.framesPerSecond = Double(framesPerSecond)
        frequencies = []
        for y in 0..<yRes {
            let baseFreq = (maxFreq - minFreq) / height * (height - Float(y)) + minFreq
            var toneFreq = baseFreq
            frequencies.append(baseFreq)
            for _ in 0..<numTones - 1 {
                toneFreq += toneDelta
                frequencies.append(toneFreq)
            }
        }
        
        Oscillator.frequencies = frequencies
    }
    
    public func generateSound(image: CGImage) {
        /*
         The format of the source asset.
         */
        let format: vImage_CGImageFormat = {
            guard
                let format = vImage_CGImageFormat(cgImage: image) else {
                    fatalError("Unable to create format.")
            }
            return format
        }()
        
        /*
         The vImage buffer containing a scaled down copy of the source asset.
         */
        
        var imageBuffer: vImage_Buffer = {
            guard
                let sourceImageBuffer = try? vImage_Buffer(cgImage: image,
                                                           format: format)
                else {
                    fatalError("Unable to create source buffers.")
            }
            return sourceImageBuffer
        }()
        

        let width = imageBuffer.width
        let height = imageBuffer.height
        
        var destinationBufferRotate: vImage_Buffer = {
            guard let destinationBuffer = try? vImage_Buffer(width: Int(height),
                                                  height: Int(width),
                                                  bitsPerPixel: 8) else {
                                                    fatalError("Unable to create destination buffers.")
            }
            return destinationBuffer
        }()
        
        var destinationBufferFlip: vImage_Buffer = {
            guard let destinationBuffer = try? vImage_Buffer(width: Int(height),
                                                  height: Int(width),
                                                  bitsPerPixel: 8) else {
                                                    fatalError("Unable to create destination buffers.")
            }
            return destinationBuffer
        }()


        // Transpose image by rotating 90 degrees and horizontal reflection
        let radians = 270 * Float.pi / 180.0
        vImageRotate_Planar8(&imageBuffer, &destinationBufferRotate, nil, radians, 0, vImage_Flags(kvImageNoFlags))
        vImageHorizontalReflect_Planar8(&destinationBufferRotate, &destinationBufferFlip, vImage_Flags(kvImageNoFlags))
        
        // Convert destinationBufferFlip into a flat [UInt8] array
        let newWidth = Int(destinationBufferFlip.width)
        let newHeight = Int(destinationBufferFlip.height)
            
        let rowBytes = destinationBufferFlip.rowBytes
        let length = newHeight * rowBytes
        let imagePtr = destinationBufferFlip.data.bindMemory(to: UInt8.self, capacity: length)
        let buffer = UnsafeBufferPointer(start: imagePtr, count: length)
        let imageArrayWithPadding = Array(buffer)
        
        colDuration = Double(1.0 / (framesPerSecond * Double(newHeight)))
        
        var all_amplitudes: [[UInt8]] = []
        for row in 0..<newHeight {
            let rowStartIndex = row * rowBytes
            let currRowSlice = imageArrayWithPadding[rowStartIndex..<rowStartIndex + newWidth]
            let currRow = Array(currRowSlice)
            
            
            var amplitudes = [UInt8](repeating: 0, count: newWidth * numTones)
            var a = 0
            for i in 0..<currRow.count {
                for _ in 0..<numTones {
                    amplitudes[a] = currRow[i]
                    a += 1
                }
            }
            all_amplitudes.append(amplitudes)
            
            

            
            
            
        }
        
        for row in 0..<newHeight {
            // Update amplitudes after colDuration seconds for all rows
            DispatchQueue.main.async {
                Timer.scheduledTimer(withTimeInterval: Double(row) * self.colDuration, repeats: false) { timer in
                    Oscillator.rowIndex = row
                }
            }
        }
        
        
        
        Oscillator.all_amplitudes = all_amplitudes
        
        
        
        

    }
}
