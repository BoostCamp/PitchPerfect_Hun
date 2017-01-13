//
//  PlaySoundsViewController.swift
//  PitchPerfect
//
//  Created by 박종훈 on 2017. 1. 5..
//  Copyright © 2017년 박종훈. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {
    @IBOutlet weak var mainStack: UIStackView!
    @IBOutlet weak var controllStack: UIStackView!
    
    @IBOutlet weak var slowButton: UIButton!
    @IBOutlet weak var fastButton: UIButton!
    @IBOutlet weak var highButton: UIButton!
    @IBOutlet weak var lowButton: UIButton!
    @IBOutlet weak var echoButton: UIButton!
    @IBOutlet weak var reverbButton: UIButton!
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    var recordedAudioURL:URL!
    var audioFile:AVAudioFile!
    var audioEngine:AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var stopTimer: Timer!
    
    var rate:Float = 1
    var pitch:Float = 0
    var echo = false
    var reverb = false
    
    enum ButtonType: Int {
        case slow = 0, fast, chipmunk, vader, echo, reverb
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudio()
        
        let unselectedSlow: UIImage = maskImg(#imageLiteral(resourceName: "Slow"))
        let unselectedFast: UIImage = maskImg(#imageLiteral(resourceName: "Fast"))
        let unselectedHigh: UIImage = maskImg(#imageLiteral(resourceName: "HighPitch"))
        let unselectedLow: UIImage = maskImg(#imageLiteral(resourceName: "LowPitch"))
        let unselectedEcho: UIImage = maskImg(#imageLiteral(resourceName: "Echo"))
        let unselectedReverb: UIImage = maskImg(#imageLiteral(resourceName: "Reverb"))
        
        slowButton.setImage(unselectedSlow, for: .normal)
        fastButton.setImage(unselectedFast, for: .normal)
        highButton.setImage(unselectedHigh, for: .normal)
        lowButton.setImage(unselectedLow, for: .normal)
        echoButton.setImage(unselectedEcho, for: .normal)
        reverbButton.setImage(unselectedReverb, for: .normal)
        
    }
    
    func maskImg(_ image: UIImage) -> UIImage{
        let rect = CGRect.init(x: 0, y: 0, width: image.size.width, height: image.size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, image.scale)
        let c : CGContext = UIGraphicsGetCurrentContext()!
        image.draw(in: rect)
        c.setFillColor(UIColor.black.withAlphaComponent(0.5).cgColor)
        c.setBlendMode(CGBlendMode.sourceAtop)
        c.fill(rect)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkViewOrientation()
        configureUI(.notPlaying)
    }

    @IBAction func playSoundForButton(_ sender: UIButton) {
        switch(ButtonType(rawValue: sender.tag)!) {
        case .slow:
            if slowButton.isSelected {
                rate = 1
                slowButton.isSelected = false
            } else {
                rate = 0.5
                slowButton.isSelected = true
                fastButton.isSelected = false
            }
        case .fast:
            if fastButton.isSelected {
                rate = 1
                fastButton.isSelected = false
            } else {
                rate = 1.5
                fastButton.isSelected = true
                slowButton.isSelected = false
            }
        case .chipmunk:
            if highButton.isSelected {
                pitch = 0
                highButton.isSelected = false
            } else {
                pitch = 1000
                highButton.isSelected = true
                lowButton.isSelected = false
            }
        case .vader:
            if lowButton.isSelected {
                pitch = 0
                lowButton.isSelected = false
            } else {
                pitch = -1000
                lowButton.isSelected = true
                highButton.isSelected = false
            }
        case .echo:
            if echoButton.isSelected {
                echo = false
                echoButton.isSelected = false
            } else {
                echo = true
                echoButton.isSelected = true
            }
        case .reverb:
            if reverbButton.isSelected {
                reverb = false
                reverbButton.isSelected = false
            } else {
                reverb = true
                reverbButton.isSelected = true
            }
        }
    }
    
    @IBAction func startButtonPressed(_ sender: Any) {
        playSound(rate: rate, pitch: pitch, echo: echo, reverb: reverb)
        configureUI(.playing)
    }
    
    @IBAction func stopButtonPressed(_ sender: AnyObject) {
        stopAudio()
    }
    
    @IBAction func shareButtonPressed(_ sender: UIView) {
        if let soundToShare = audioFile {
            let objectsToShare = [soundToShare] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            //New Excluded Activities Code
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
            //
            
            activityVC.popoverPresentationController?.sourceView = sender
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        checkViewOrientation()
    }
    
    func checkViewOrientation() {
        if UIDevice.current.orientation.isLandscape {
            mainStack.axis = .horizontal
            controllStack.axis = .vertical
            controllStack.spacing = 2.0
            startButton.heightAnchor.constraint(lessThanOrEqualToConstant: 70)
            
        } else {
            mainStack.axis = .vertical
            controllStack.axis = .horizontal
        }
    }
}
