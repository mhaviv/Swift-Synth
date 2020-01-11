//
//  SynthSound.swift
//  Swift Synth
//
//  Created by Michael Haviv on 1/9/20.
//  Copyright © 2020 Michael Haviv. All rights reserved.
//

import Foundation
import AVFoundation

class Synth {
 
    // MARK: Properties
    public static let shared = Synth() // singelton (to accesss it from any view controller)
    
    // allows to simulate turning the synth on and off
    public var volume: Float {
        set {
            audioEngine.mainMixerNode.outputVolume = newValue
        }
        get {
            return audioEngine.mainMixerNode.outputVolume
        }
    }
    // AVAudioEngine hosts the sound making AVAudioNodes that are added to the signal chain
    private var audioEngine: AVAudioEngine
    private var time: Float = 0
    private let sampleRate: Double
    private let deltaTime: Float
    
    /*
     lazily referencing sourceNode since we are referenceing self
     
     */
    private lazy var sourceNode = AVAudioSourceNode { (_, _, frameCount, audioBufferList) -> OSStatus in
        let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
        for frame in 0..<Int(frameCount) {
            let sampleVal = self.signal(self.time)
            self.time += self.deltaTime
            for buffer in ablPointer {
                let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
                buf[frame] = sampleVal
            }
        }
        return noErr
    }
    
    private var signal: Signal

    
    // MARK: Init
 
    init() {
        audioEngine = AVAudioEngine()
        
        // mainMixerNode is a singelton connected to the outputNode that acts as a intermediary between the source nodes and the outputNode
        let mainMixer = audioEngine.mainMixerNode
        let outputNode = audioEngine.outputNode
        // provides the default audio settings for the device we are working with
        let format = outputNode.inputFormat(forBus: 0)
        
        sampleRate = format.sampleRate
        // duration each sample is held for (ex: 1/44100 to represent each of the samples
        deltaTime = 1 / Float(sampleRate)
    }
 
    // MARK: Public Functions
    
}

// Takes in one float to represent time and returns one float for the audio sample
typealias Signal = (Float) -> (Float)
