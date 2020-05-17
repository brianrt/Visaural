//
//  Utilities.swift
//  Swift Synth
//
//  Created by Brian Thompson on 5/12/20.
//  Copyright © 2020 Grant Emerson. All rights reserved.
//

import AVFoundation
import Accelerate

class ImageProcessing {
    
    var sourceBuffer: vImage_Buffer!
    var destinationBuffer: vImage_Buffer!
    
    // Declare the three coefficients that model the eye's sensitivity
    // to color.
    let redCoefficient: Float = 0.2126
    let greenCoefficient: Float = 0.7152
    let blueCoefficient: Float = 0.0722
    

    // Use the matrix of coefficients to compute the scalar luminance by
    // returning the dot product of each RGB pixel and the coefficients
    // matrix.
    let preBias: [Int16] = [0, 0, 0, 0]
    let postBias: Int32 = 0
    var coefficientsMatrix: [Int16] = [0]

    func convertToGray(cgImage: CGImage) -> CGImage? {
        /*
         The format of the source asset.
         */
        let format: vImage_CGImageFormat = {
            guard
                let format = vImage_CGImageFormat(cgImage: cgImage) else {
                    fatalError("Unable to create format.")
            }
            
            return format
        }()
        
        /*
         The vImage buffer containing a scaled down copy of the source asset.
         */
        self.sourceBuffer = {
            guard
                var sourceImageBuffer = try? vImage_Buffer(cgImage: cgImage,
                                                           format: format),
                
                var scaledBuffer = try? vImage_Buffer(width: Int(sourceImageBuffer.width / 10),
                                                      height: Int(sourceImageBuffer.height / 10),
                                                      bitsPerPixel: format.bitsPerPixel) else {
                                                        fatalError("Unable to create source buffers.")
            }
            
            defer {
                sourceImageBuffer.free()
            }
            
            vImageScale_ARGB8888(&sourceImageBuffer,
                                 &scaledBuffer,
                                 nil,
                                 vImage_Flags(kvImageNoFlags))
            
            return scaledBuffer
        }()
        
        /*
         The 1-channel, 8-bit vImage buffer used as the operation destination.
         */
        self.destinationBuffer = {
            guard let destinationBuffer = try? vImage_Buffer(width: Int(sourceBuffer.width),
                                                  height: Int(sourceBuffer.height),
                                                  bitsPerPixel: 8) else {
                                                    fatalError("Unable to create destination buffers.")
            }
            
            return destinationBuffer
        }()
        
        // Create a 1D matrix containing the three luma coefficients that
        // specify the color-to-grayscale conversion.
        let divisor: Int32 = 0x1000 // 16^3 = 4096
        let fDivisor = Float(divisor)
        
        self.coefficientsMatrix = [
            Int16(redCoefficient * fDivisor),
            Int16(greenCoefficient * fDivisor),
            Int16(blueCoefficient * fDivisor)
        ]
        
        vImageMatrixMultiply_ARGB8888ToPlanar8(&self.sourceBuffer,
                                               &self.destinationBuffer,
                                               &self.coefficientsMatrix,
                                               divisor,
                                               preBias,
                                               postBias,
                                               vImage_Flags(kvImageNoFlags))
        
        // Create a 1-channel, 8-bit grayscale format that's used to
        // generate a displayable image.
        guard let monoFormat = vImage_CGImageFormat(
            bitsPerComponent: 8,
            bitsPerPixel: 8,
            colorSpace: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue),
            renderingIntent: .defaultIntent) else {
                return nil
        }
        
        // Create a Core Graphics image from the grayscale destination buffer.
        let result = try? destinationBuffer.createCGImage(format: monoFormat)
        cleanUp()
        return result
    }
    
    func cleanUp(){
        // Clear everything from memory
        destinationBuffer.free()
        sourceBuffer.free()
        coefficientsMatrix.removeAll()
    }
}
