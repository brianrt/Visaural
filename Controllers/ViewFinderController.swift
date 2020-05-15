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
    var previewView: UIView!
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
    
    override func viewDidLoad() {
        //Initialize the subViews
        previewView = UIView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.width/2, height: self.view.frame.height))
        captureImageView = UIImageView.init(frame: CGRect(x: self.view.frame.width/2, y: 0, width: self.view.frame.width/2, height: self.view.frame.height))
        self.view.add(previewView)
        self.view.add(captureImageView)
        
        // Initialize queues
        let highQueue = DispatchQueue.global(qos: .userInteractive)
        videoDataOutputQueue = DispatchQueue(label: "com.apple.sample.capturepipeline.video", attributes: [], target: highQueue)
        
        // Create new session
        // Configure session for high resolution still photo capture
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .medium
        
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
            videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
            videoConnection = videoDataOutput.connection(with: AVMediaType.video)
            
            if captureSession.canAddInput(input) && captureSession.canAddOutput(videoDataOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(videoDataOutput)
                setupLivePreview()
            }
        }
        catch let error  {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }
        
        //Initialize driver and start timer
        driver = Driver()
        start()
    }

    // Configure the Live Preview
    func setupLivePreview() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspect
        videoPreviewLayer.connection?.videoOrientation = .landscapeRight
        self.previewView.layer.addSublayer(videoPreviewLayer)
        
        // Start the Session on the background thread
        DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
            self.captureSession.startRunning()
            
            
            // Size the Preview Layer to fit the Preview View
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.previewView.bounds
            }
        }
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let imageBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        let ciimage : CIImage = CIImage(cvPixelBuffer: imageBuffer)
        let cgImage: CGImage = self.convert(cmage: ciimage)
        
        // Size the Preview Layer to fit the Preview View
        DispatchQueue.main.async {
            self.currImage = cgImage
        }
    }

    func start() {
        let timeInterval = 1 / self.framesPerSecond
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: { timer in
            self.processImage()
        })
    }

    func processImage() {
        if self.currImage != nil {
            let cgImage = self.driver.processImage(image: self.currImage)
            if cgImage != nil {
                self.captureImageView.image = UIImage.init(cgImage: cgImage!)
            }
        }
    }
    
    // Convert CIImage to CGImage
    func convert(cmage:CIImage) -> CGImage
    {
         let context:CIContext = CIContext.init(options: nil)
         let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
         return cgImage
    }
}
