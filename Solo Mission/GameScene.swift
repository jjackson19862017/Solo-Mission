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
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    func random(min:CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max-min) + min
    }
    
    
    
    let gameArea: CGRect // Sets a rectangle
    
    override init(size: CGSize) {
        
        let maxAspectRatio: CGFloat = 16.0/9.0 // 16:9 Screens
        let playableWidth = size.height / maxAspectRatio // Sets area that is seen on all devices
        let margin = (size.width - playableWidth) / 2 // Works out equal size margins
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
        startNewLevel()
    }
    
    func startNewLevel() {
        
        let spawn = SKAction.run(spawnEnemy)
        let waitToSpawn = SKAction.wait(forDuration: 1)
        let spawnSequence = SKAction.sequence([spawn, waitToSpawn])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever)
        
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
    
    func spawnEnemy() {
        
        let randomXStart = random(min: gameArea.minX, max: gameArea.maxX)
        let randomXEnd = random(min: gameArea.minX, max: gameArea.maxX)
        
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2) // Works out 20% more that the height of area
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2) // Works out 20% below the height of area
    
        let enemy = SKSpriteNode(imageNamed: "enemyShip")
        enemy.setScale(1) // If you want the enemy bigger you can change it to a higher number
        enemy.position = startPoint // Sets the enemys position
        enemy.zPosition = 2 // Same level as players ship
        self.addChild(enemy) // Creates the enemy Object
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 1.5) // Move enemy from top to bottom of screen
        let deleteEnemy = SKAction.removeFromParent() // Deletes enemy from memory
        let enemySquence = SKAction.sequence([moveEnemy, deleteEnemy]) // Once enemy has reached the bottom of the screen, Delete it
        enemy.run(enemySquence) // Run enemy sequence
    
        // Allows to rotate an image from facing right to looking down.
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountToRotate = atan2(dy, dx)
        enemy.zRotation = amountToRotate
        
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
            // If the ship goes to far Right, the player.size.width allows all the ship to stay on screen instead of half
            if player.position.x > gameArea.maxX - player.size.width/2{
                player.position.x = gameArea.maxX - player.size.width/2
            }
            // If the ship goes to far Left, the player.size.width allows all the ship to stay on screen instead of half
            if player.position.x < gameArea.minX + player.size.width/2 {
                player.position.x = gameArea.minX + player.size.width/2
                }
            
        }
        
    }
}
