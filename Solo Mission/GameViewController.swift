//
//  GameViewController.swift
//  Solo Mission
//
//  Created by Stephen Jackson on 30/04/2020.
//  Copyright © 2020 Stephen Jackson. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation


class GameViewController: UIViewController {

    var backingAudio = AVAudioPlayer()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let filePath = Bundle.main.path(forResource: "backingaudio", ofType: "mp3")
        let audioNSURL = NSURL(fileURLWithPath: filePath!)
        
        // Required by Apple as error catching
        do { backingAudio = try AVAudioPlayer(contentsOf: audioNSURL as URL)}
        catch { return print("Cannot Find The Audio")}
        
        backingAudio.numberOfLoops = -1 // Loops forever
        backingAudio.play()
        
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
             let scene = mainMenuScene(size: CGSize(width: 1536, height: 2048))
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = false
            view.showsNodeCount = false
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
