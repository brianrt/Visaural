//
//  ViewController.swift
//  Swift Synth
//
//  Created by Grant Emerson on 7/21/19.
//  Copyright © 2019 Grant Emerson. All rights reserved.
//

import UIKit

class SynthViewController: UIViewController {
    
    // MARK: Properties
    
    private lazy var parameterLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "Frequency: 0 Hz  Amplitude: 0%"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: View Controller Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        Synth.shared.setWaveformTo(Oscillator.sine)
        setUpView()
        setUpSubviews()
    }
    
    // MARK: Implement Touches Functions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let coord = touch.location(in: view)
        setSynthParametersFrom(coord)
        setPlaybackStateTo(true)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let coord = touch.location(in: view)
        setSynthParametersFrom(coord)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        setPlaybackStateTo(false)
        parameterLabel.text = "Frequency: 0 Hz  Amplitude: 0%"
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        setPlaybackStateTo(false)
        parameterLabel.text = "Frequency: 0 Hz  Amplitude: 0%"
    }
    
    // MARK: Selector Functions
    
    @objc private func updateOscillatorWaveform() {
        
    }
    
    @objc private func setPlaybackStateTo(_ state: Bool) {
        Synth.shared.volume = state ? 1.0 : 0
    }
    
    // MARK: Private Functions
    
    private func setUpView() {
        view.backgroundColor = #colorLiteral(red: 0.1607843137, green: 0.1647058824, blue: 0.1882352941, alpha: 1)
        view.isMultipleTouchEnabled = false
    }
    
    private func setUpSubviews() {
        view.add(parameterLabel)
        
        NSLayoutConstraint.activate([
            parameterLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10)
        ])
    }
    
    private func setSynthParametersFrom(_ coord: CGPoint) {
//        Oscillator.amplitude = Float((view.bounds.height - coord.y) / view.bounds.height)
//        Synth.shared.frequency = Float(coord.x / view.bounds.width) * 1014 + 32
        
//        let amplitudePercent = Int(Oscillator.amplitude * 100)
        let frequencyHertz = Int(Synth.shared.frequency)
//        parameterLabel.text = "Frequency: \(frequencyHertz) Hz  Amplitude: \(amplitudePercent)%"
    }
}
