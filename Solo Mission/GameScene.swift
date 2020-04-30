//
//  GameScene.swift
//  Solo Mission
//
//  Created by Stephen Jackson on 30/04/2020.
//  Copyright © 2020 Stephen Jackson. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let player = SKSpriteNode(imageNamed: "playerShip") // Declare a Player
    let bulletsound = SKAction.playSoundFileNamed("laser.wav", waitForCompletion: false) // Load sound effect to cancel any lag
    let explodesound = SKAction.playSoundFileNamed("impact.caf", waitForCompletion: false) // Load sound effect to cancel any lag
    
    struct PhysicsCategories {
        static let None : UInt32 = 0
        static let Player : UInt32 = 0b1 // 1
        static let Bullet : UInt32 = 0b10 // 2
        static let Enemy : UInt32 = 0b100 // 4
    }
    
    
    
    
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
        
        self.physicsWorld.contactDelegate = self // Collision Detection
        
        
        
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
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size) // Makes the player have a physic property
        player.physicsBody!.affectedByGravity = false // Not affected by gravity
        player.physicsBody!.categoryBitMask = PhysicsCategories.Player // Sets Physics Category
        player.physicsBody!.collisionBitMask = PhysicsCategories.None // Turns off Collisions
        player.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy  // Has Contact with Enemy and lets us know
        self.addChild(player) // Creates the player Object
        
        startNewLevel()
    }
    
    // Did the Objects have contact with each other?
    func didBegin(_ contact: SKPhysicsContact) {
        
        // Setups so that the contacts are in number order and the lowest category is always lowest
        //struct PhysicsCategories
        //       static let None : UInt32 = 0
        //       static let Player : UInt32 = 0b1 // 1
        //       static let Bullet : UInt32 = 0b10 // 2
        //       static let Enemy : UInt32 = 0b100 // 4
        // So basically Bullet will be body1 and enemy body2
        // and Player will be body1 and enemy body2
        
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            body1 = contact.bodyA
            body2 = contact.bodyB
        }
        else {
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Enemy{
            // If the player has hit the enemy
            
            if body1.node != nil {
                // Only run if object exists, avoids crashing game
                spawnExplosion(spawnPosition: body1.node!.position)
            }
            if body2.node != nil {
                // Only run if object exists, avoids crashing game
            spawnExplosion(spawnPosition: body2.node!.position)
            }
            
            body1.node?.removeFromParent() // Delete Player
            body2.node?.removeFromParent() // Delete Enemy
        }
        
        if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Enemy {
            // If the bullet has hit the enemy
            
            if body2.node != nil {
            // Only run if object exists, avoids crashing game
                if body2.node!.position.y > self.size.height{
                    return //if the enemy is off the top of the screen, 'return'. This will stop running this code here, therefore doing nothing unless we hit the enemy when it's on the screen. As we are already checking that body2.node isn't nothing, we can safely unwrap (with '!)' this here.
                }
                else{
            spawnExplosion(spawnPosition: body2.node!.position)
                }
                
            }
            
            
            body1.node?.removeFromParent() // Delete Bullet
            body2.node?.removeFromParent() // Delete Enemy
        }
        
    }
    
    func spawnExplosion(spawnPosition: CGPoint){
        
        let explosion = SKSpriteNode(imageNamed: "explode")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.setScale(0)
        self.addChild(explosion)
        
        let scaleIn = SKAction.scale(to: 1, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        
        let explosionSequence = SKAction.sequence([explodesound, scaleIn, fadeOut, delete])
    
        explosion.run(explosionSequence)
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
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size) // Makes the bullet have a physic property
        bullet.physicsBody!.affectedByGravity = false // Not affected by gravity
        bullet.physicsBody!.categoryBitMask = PhysicsCategories.Bullet // Sets Physics Category
        bullet.physicsBody!.collisionBitMask = PhysicsCategories.None // Turns off Collisions
        bullet.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy // Has Contact with Enemy and lets us know
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
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size) // Makes the enemy have a physic property
        enemy.physicsBody!.affectedByGravity = false // Not affected by gravity
        enemy.physicsBody!.categoryBitMask = PhysicsCategories.Enemy // Sets Physics Category
        enemy.physicsBody!.collisionBitMask = PhysicsCategories.None // Turns off Collisions
        enemy.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet // Has Contact and lets us know
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
