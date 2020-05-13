//
//  Driver.swift
//  Swift Synth
//
//  Created by Brian Thompson on 5/12/20.
//

import AVFoundation

class Driver {
    var framesPerSecond = 30.0
    var minFreq = 1000
    var maxFreq = 8000
    var height = 100
    
    // Not initialized in constructor
    var width: Int!
    var image: CGImage!
    var processedImage: CGImage!
    
    // Callback function for image updating
    var imageCallBackFunction: (_ cgImage: CGImage) -> ()
    
    var imageProcessor = ImageProcessing()
    
    init(imageCallBack: @escaping (_ cgImage: CGImage) -> ()) {
        self.imageCallBackFunction = imageCallBack
    }
    
    public func start() {
        let timeInterval = 1 / self.framesPerSecond
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: { timer in
            if self.image != nil {
                self.processedImage = self.imageProcessor.convertToGray(cgImage: self.image!)
                if (self.processedImage != nil) {
                    self.imageCallBackFunction(self.processedImage!)
                }
            }
        })
    }
    
    public func setImage(image: CGImage) {
        self.image = image
    }
}
