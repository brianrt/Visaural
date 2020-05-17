//
//  ViewFinderController.swift
//  Swift Synth
//
//  Created by Brian Thompson on 5/7/20.
//  Copyright © 2020 Grant Emerson. All rights reserved.
//

import UIKit
import AVFoundation

class ViewFinderController: UIViewController, AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    var captureImageView: UIImageView!
    var button: UIButton!
    var currImage: CGImage!
    
    var captureSession: AVCaptureSession!
    var videoDataOutput: AVCaptureVideoDataOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var videoConnection: AVCaptureConnection?
    var videoDataOutputQueue: DispatchQueue!
    
    var framesPerSecond = 30.0
    var driver: Driver!
    
    var didSetFrame = false

    override func viewDidLoad() {
        //Initialize the subViews
        captureImageView = UIImageView.init()
        self.view.add(captureImageView)
        
        // Initialize queues
        let dataOutputQueue = DispatchQueue(label: "video data queue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
        
        // Create new session
        // Configure session for high resolution still photo capture
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo

        
        // Select input camera
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
            else {
                print("Unable to access back camera!")
                return
        }
        
        // Prepare the input and output
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            videoDataOutput = AVCaptureVideoDataOutput()
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
            videoDataOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)
            videoConnection = videoDataOutput.connection(with: AVMediaType.video)
            
            if captureSession.canAddInput(input) && captureSession.canAddOutput(videoDataOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(videoDataOutput)
            }
        }
        catch let error  {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }
        
        // Set framerate
        do {
            try backCamera.lockForConfiguration()
            backCamera.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: Int32(self.framesPerSecond))
            backCamera.unlockForConfiguration()
        } catch {
            print("Could not lock")
        }

        //Initialize driver
        driver = Driver()
        self.captureSession.startRunning()
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        //Lock the pixel buffer
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.readOnly)
        let ciimage: CIImage = CIImage(cvPixelBuffer: pixelBuffer)
        let cgImage: CGImage = self.convert(cmage: ciimage)


        // Process image
        let outImage = self.driver.processImage(image: cgImage)
        if outImage != nil {
            DispatchQueue.main.async {
                if !self.didSetFrame {
                    self.setFrame(cgImage: outImage!)
                }
                self.captureImageView.image = UIImage.init(cgImage: outImage!)
            }
        }

        // Unlock pixel buffer
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.readOnly)
    }

    // Convert CIImage to CGImage
    func convert(cmage:CIImage) -> CGImage
    {
         let context:CIContext = CIContext.init(options: nil)
         let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
         return cgImage
    }

    // Sets frame
    func setFrame(cgImage: CGImage) {
        let viewFrame = self.view.frame
        let ratio = Float(cgImage.width) / Float(cgImage.height)

        if viewFrame.width < viewFrame.height {
            let newHeight = Float(viewFrame.width) / ratio
            self.captureImageView.frame = CGRect(x: (viewFrame.width - CGFloat(viewFrame.width))/2.0, y: 0, width: viewFrame.width, height: CGFloat(newHeight))
        } else {
            let newWidth = Float(viewFrame.height) * ratio
            self.captureImageView.frame = CGRect(x: (viewFrame.width - CGFloat(newWidth))/2.0, y: 0, width: CGFloat(newWidth), height: viewFrame.height)
        }
        self.didSetFrame = true
    }
}
