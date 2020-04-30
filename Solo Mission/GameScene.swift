//
//  GameScene.swift
//  Solo Mission
//
//  Created by Stephen Jackson on 30/04/2020.
//  Copyright © 2020 Stephen Jackson. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    let player = SKSpriteNode(imageNamed: "playerShip") // Declare a Player
    let bulletsound = SKAction.playSoundFileNamed("bulletsound.wav", waitForCompletion: false) // Load sound effect to cancel any lag
    
    override func didMove(to view: SKView) {
        
        // Setup Background Scene
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size // Sets background to the scene size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2) // Centers it both horizontal and vertical
        background.zPosition = 0 // Sets background to the bottom so other objects sit on top of it.
        self.addChild(background) // Creates the background Object
        
        // Setup Player
        player.setScale(1) // If you want the ship bigger you can change it to a higher number
        player.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.2) // Puts it in the middle of the screen horizontally, and 20% from the bottom of the screen
        player.zPosition = 2 // Its not 1 because the bullets will be 1
        self.addChild(player) // Creates the player Object
    }
    
    func fireBullet() {
        
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.setScale(1) // If you want the bullet bigger you can change it to a higher number
        bullet.position = player.position // Sets the bullet firing position
        bullet.zPosition = 1 // This will be underneath the Ship but on top of the background
        self.addChild(bullet) // Creates the bullet Object
        
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1) // Move bullet from ship to top of screen
        let deleteBullet = SKAction.removeFromParent() // Deletes bullet from memory
        let bulletSequence = SKAction.sequence([bulletsound, moveBullet, deleteBullet]) // Once bullet has reached the top of the screen, Delete it
        bullet.run(bulletSequence) // Run bullet sequence
    }
    
    // When screen is touched
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        fireBullet()
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            
            let pointOfTouch = touch.location(in: self) // New point of touch
            let previousPointOfTouch = touch.previousLocation(in: self) // Previous point of touch
            
            let amountDragged = pointOfTouch.x - previousPointOfTouch.x // Work out difference
            
            player.position.x += amountDragged // Moves ship left or right
            
        }
        
    }
}
