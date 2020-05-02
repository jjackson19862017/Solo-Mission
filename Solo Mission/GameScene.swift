//
//  GameScene.swift
//  Solo Mission
//
//  Created by Stephen Jackson on 30/04/2020.
//  Copyright © 2020 Stephen Jackson. All rights reserved.
//

import SpriteKit
import GameplayKit

var gameScore = 0

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    let scoreLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    var levelNumber = 0
    
    var livesNumber = 3
    let livesLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    
    let player = SKSpriteNode(imageNamed: "playerShip") // Declare a Player
    let bulletsound = SKAction.playSoundFileNamed("laser.wav", waitForCompletion: false) // Load sound effect to cancel any lag
    let explodesound = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false) // Load sound effect to cancel any lag
    
    let tapToStartLabel = SKLabelNode(fontNamed: "The Bold Font")
    enum gameState{
        case preGame // Before start of game
        case inGame // During game
        case afterGame // After the game, when its finished
    }
    
    var currentGameState = gameState.preGame
    
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
        
        gameScore = 0
        
        
        self.physicsWorld.contactDelegate = self // Collision Detection
        
        
        
        // Setup Background Scene
        for i in 0...1{
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size // Sets background to the scene size
        background.anchorPoint = CGPoint(x: 0.5, y: 0) // Sets the Anchor point to the bottom middle of the screen
        background.position = CGPoint(x: self.size.width/2,
                                      y: self.size.height*CGFloat(i)) // Centers it horizontal and the first background sits at the bottom of the screen and the second background view sits at the top of the screen
        background.zPosition = 0 // Sets background to the bottom so other objects sit on top of it.
        background.name = "Background"
        self.addChild(background) // Creates the background Object
        }
        // Setup Player
        player.setScale(1) // If you want the ship bigger you can change it to a higher number
        player.position = CGPoint(x: self.size.width/2, y: self.size.height * 0 - player.size.height) // Puts it in the middle of the screen horizontally, and off the bottom of the screen
        player.zPosition = 2 // Its not 1 because the bullets will be 1
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size) // Makes the player have a physic property
        player.physicsBody!.affectedByGravity = false // Not affected by gravity
        player.physicsBody!.categoryBitMask = PhysicsCategories.Player // Sets Physics Category
        player.physicsBody!.collisionBitMask = PhysicsCategories.None // Turns off Collisions
        player.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy  // Has Contact with Enemy and lets us know
        self.addChild(player) // Creates the player Object
        
        scoreLabel.text = "Score: 0" // Set Default Text
        scoreLabel.fontSize = 70 // Font Size
        scoreLabel.fontColor = SKColor.white // Font Colour
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left // Label Alignment to the Left
        scoreLabel.position = CGPoint(x: self.size.width*0.15, y: self.size.height + scoreLabel.frame.size.height) // X is going to be 15% across the screen so its not choped off any devices, Y is going to be off the screen
        scoreLabel.zPosition = 100 // Z Value is High so its on top of everything
        self.addChild(scoreLabel) // Create the scoreLabel
        
        livesLabel.text = "Lives: 3" // Set Default Text
        livesLabel.fontSize = 70 // Font Size
        livesLabel.fontColor = SKColor.white // Font Colour
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right // Label Alignment to the Left
        livesLabel.position = CGPoint(x: self.size.width*0.85, y: self.size.height + livesLabel.frame.size.height) // X is going to be 85% across the screen so its not choped off any devices, Y is going to be off the screen
        livesLabel.zPosition = 100 // Z Value is High so its on top of everything
        self.addChild(livesLabel) // Create the scoreLabel
        
        let moveOnToScreenAction = SKAction.moveTo(y: self.size.height*0.9, duration: 0.3)
        scoreLabel.run(moveOnToScreenAction)
        livesLabel.run(moveOnToScreenAction)
        
        
        tapToStartLabel.text = "Tap To Begin" // Set Default Text
        tapToStartLabel.fontSize = 100 // Font Size
        tapToStartLabel.fontColor = SKColor.white // Font Colour
        tapToStartLabel.zPosition = 1 // Z Value is on top of background
        tapToStartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2) // Middle of Screen
        tapToStartLabel.alpha = 0 // Make it invisible
        self.addChild(tapToStartLabel) // Create the tapToStartLabel
        
        let fadeInAction = SKAction.fadeIn(withDuration: 0.3) // Fade in over 0.3 Seconds
        tapToStartLabel.run(fadeInAction)
       
    
    }
    
    var lastUpdateTime: TimeInterval = 0
    var deltaFrameTime: TimeInterval = 0
    var amountToMovePerSecond: CGFloat = 600.0
    
    // Runs every frame of the game
    override func update(_ currentTime: TimeInterval) {
        // We need to workout how much time has elapsed
        
        // This is the first frame
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime // Updates to current time
        }
        else {
            deltaFrameTime = currentTime - lastUpdateTime // How much time has passed
            lastUpdateTime = currentTime // Updates to current time
        }
        
        let amountToMoveBackground = amountToMovePerSecond * CGFloat(deltaFrameTime)
        
        self.enumerateChildNodes(withName: "Background"){
            (background, stop) in
            
            if self.currentGameState == gameState.inGame{
            background.position.y -= amountToMoveBackground
            }
            if background.position.y < -self.size.height {
                background.position.y += self.size.height*2
            }
        }
    }
    
    func startGame(){
        
        currentGameState = gameState.inGame // Changes Game State to be in Game
        
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5) // Fades out
        let deleteAction = SKAction.removeFromParent() // Deletes
        let deleteSequence = SKAction.sequence([fadeOutAction, deleteAction]) // Fades out and then deletes Tap To Start Label
        tapToStartLabel.run(deleteSequence) // Runs Sequence
        
        let moveShipOntoScreenAction = SKAction.moveTo(y: self.size.height*0.2, duration: 0.5) // Moves player ship on to screen
        let startLevelAction = SKAction.run(startNewLevel) // Runs the startNewLevel Block
        let startGameSequence = SKAction.sequence([moveShipOntoScreenAction, startLevelAction]) // Moves ship then starts game
        player.run(startGameSequence) // Runs Sequence
        
    }
    
    
    
    func loseALife(){
        
        livesNumber -= 1
        livesLabel.text = "Lives: \(livesNumber)"
        
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        livesLabel.run(scaleSequence)
        
        if livesNumber == 0 {
            runGameOver()
        }
        
    }
    
    func addScore() {
        gameScore += 1
        scoreLabel.text = "Score: \(gameScore)"
        
        if gameScore == 10 || gameScore == 25 || gameScore == 50 {
            startNewLevel()
        }
    }
    
    func runGameOver(){
        
        currentGameState = gameState.afterGame
        // Freezes all objects on screen
        self.removeAllActions()

        self.enumerateChildNodes(withName: "Bullet"){
            (bullet, stop) in
            bullet.removeAllActions()
        }
        
        self.enumerateChildNodes(withName: "Enemy"){
            (enemy, stop) in
            enemy.removeAllActions()
        }
        
        let changeSceneAction = SKAction.run(changeScene)
        let waitToChangeScene = SKAction.wait(forDuration: 1)
        let changeSceneSequence = SKAction.sequence([waitToChangeScene, changeSceneAction])
        self.run(changeSceneSequence)
    }
    
    func changeScene(){
        let sceneToMoveTo = GameOverScene(size: self.size) // Sets the GameOverScene as the same size as game screen
        sceneToMoveTo.scaleMode = self.scaleMode // Sets the GameOverScene as the same scale as game screen
        let myTransition = SKTransition.fade(withDuration: 0.5) // Fades to the next scene over half a second
        self.view!.presentScene(sceneToMoveTo, transition: myTransition)
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
            
            runGameOver()
        }
        
        if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Enemy {
            // If the bullet has hit the enemy
            
            addScore()
            
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
        
        let scaleIn = SKAction.scale(to: 3, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        
        let explosionSequence = SKAction.sequence([explodesound, scaleIn, fadeOut, delete])
    
        explosion.run(explosionSequence)
    }
    
    
    
    func startNewLevel() {
        
        levelNumber += 1
        // Stops Sequence from running
        if self.action(forKey: "spawningEnemies") != nil {
            // If this is running it will stop spawning enemies
            self.removeAction(forKey: "spawningEnemies")
        }
        
        var levelDuration = TimeInterval()
        
        switch levelNumber {
        case 1: levelDuration = 1.2
        case 2: levelDuration = 1
        case 3: levelDuration = 0.8
        case 4: levelDuration = 0.5
        default:
            levelDuration = 0.5
            print("Cannot find level info")
        }
        
        let spawn = SKAction.run(spawnEnemy)
        let waitToSpawn = SKAction.wait(forDuration: levelDuration)
        let spawnSequence = SKAction.sequence([waitToSpawn, spawn ])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever, withKey: "spawningEnemies") // Assigns a key to this section of code
        
    }
    
    
    
    
    func fireBullet() {
        
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.name = "Bullet"
        bullet.setScale(1.5) // If you want the bullet bigger you can change it to a higher number
        bullet.position = player.position // Sets the bullet firing position
        bullet.zPosition = 1 // This will be underneath the Ship but on top of the background
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size) // Makes the bullet have a physic property
        bullet.physicsBody!.affectedByGravity = false // Not affected by gravity
        bullet.physicsBody!.categoryBitMask = PhysicsCategories.Bullet // Sets Physics Category
        bullet.physicsBody!.collisionBitMask = PhysicsCategories.None // Turns off Collisions
        bullet.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy // Has Contact with Enemy and lets us know
        self.addChild(bullet) // Creates the bullet Object
        
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 3) // Move bullet from ship to top of screen
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
        enemy.name = "Enemy"
        enemy.setScale(1.5) // If you want the enemy bigger you can change it to a higher number
        enemy.position = startPoint // Sets the enemys position
        enemy.zPosition = 2 // Same level as players ship
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size) // Makes the enemy have a physic property
        enemy.physicsBody!.affectedByGravity = false // Not affected by gravity
        enemy.physicsBody!.categoryBitMask = PhysicsCategories.Enemy // Sets Physics Category
        enemy.physicsBody!.collisionBitMask = PhysicsCategories.None // Turns off Collisions
        enemy.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet // Has Contact and lets us know
        self.addChild(enemy) // Creates the enemy Object
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 3) // Move enemy from top to bottom of screen
        let deleteEnemy = SKAction.removeFromParent() // Deletes enemy from memory
        let loseALifeAction = SKAction.run(loseALife) // Runs the block LoseALife
        let enemySquence = SKAction.sequence([moveEnemy, deleteEnemy, loseALifeAction]) // Once enemy has reached the bottom of the screen, Delete it
        
        // If the game is inGame
        if currentGameState == gameState.inGame {
        enemy.run(enemySquence) // Run enemy sequence
        }
        
        // Allows to rotate an image from facing right to looking down.
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountToRotate = atan2(dy, dx)
        enemy.zRotation = amountToRotate
        
    }
    
    
    
    // When screen is touched
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // If the game is preGame
        if currentGameState == gameState.preGame {
            startGame()
        }
        
        // If the game is inGame
            // The else stops a bullet from being fired straight away
        else if currentGameState == gameState.inGame {
        fireBullet()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            
            let pointOfTouch = touch.location(in: self) // New point of touch
            let previousPointOfTouch = touch.previousLocation(in: self) // Previous point of touch
            
            let amountDragged = pointOfTouch.x - previousPointOfTouch.x // Work out difference
            
            // If the game is inGame
            if currentGameState == gameState.inGame {
            player.position.x += amountDragged // Moves ship left or right
            }
            
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
