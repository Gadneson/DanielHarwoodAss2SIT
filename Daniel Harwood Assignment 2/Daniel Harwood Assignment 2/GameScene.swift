//
//  GameScene.swift
//  Daniel Harwood Assignment 2
//
//  Created by Daniel Harwood on 26/5/18.
//  Copyright © 2018 Deakin. All rights reserved.
//

import SpriteKit
import GameplayKit

// GLOBAL VARIABLES
var gameScore = 0
var muted = false
var player = SKSpriteNode(imageNamed: "RedShip")

// Mute Button
let muteLabel = SKLabelNode(fontNamed: "Arial")




class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // GAME SCENE LABELS
    let tapToStartLabel = SKLabelNode(fontNamed: "Arial")
    let scoreLabel = SKLabelNode (fontNamed: "Arial")
    let livesLabel = SKLabelNode(fontNamed: "Arial")
    
    // GAME SCENE VARIABLES
    var gameArea: CGRect
    var livesNumber = 3
    var levelNumber = 0
    
    
    //GAME SCENE SOUNDS
    let bulletSound = SKAction.playSoundFileNamed("pew.wav", waitForCompletion: false)
    let explosionSound = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
    
    //GAME STATES
    enum gameState{
        case preGame
        case inGame
        case afterGame
    }
    
    //STARTING GAME STATES
    var currentGameState = gameState.preGame
    
    
    struct PhysicsCategories{
        static let None : UInt32 = 0
        static let player: UInt32 = 0b1 //1
        static let Bullet : UInt32 = 0b10 //2
        static let Enemy : UInt32 = 0b100 //4
    }
    
 
    // GAME AREA CONTAINER DETAILS
    override init(size: CGSize){
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableWidth = size.height / maxAspectRatio
        let margin = (size.width - playableWidth) / 2
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        super.init(size: size)
    }
    
    //MANDITORY CODE
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //GENERATE A RANDOM BUMBER
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    //GENERATE A MINIMUM AND MAXIMUM
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    
    override func didMove(to view: SKView) {
        
        gameScore = 0
        
        self.physicsWorld.contactDelegate = self
        
        
        //BACKGROUND DETAILS
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y:self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        
        //PLAYER DETAILS
        player.setScale(1.5)
        player.position = CGPoint(x: self.size.width/2 , y: 0 - player.size.height)
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = PhysicsCategories.player
        player.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(player)
        
        //SCORE COUNTER DETAILS
        scoreLabel.text = "score: 0"
        scoreLabel.fontSize = 70
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: self.size.width*0.15, y: self.size.height*0.9)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
        
        
        //LIVES COUNTER DETAILS
        livesLabel.text = "Lives: 3"
        livesLabel.fontSize = 70
        livesLabel.fontColor = SKColor.white
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        livesLabel.position = CGPoint(x: self.size.width*0.85, y: self.size.height*0.9)
        livesLabel.zPosition = 100
        self.addChild(livesLabel)
        
        //START BUTTON LABEL
        tapToStartLabel.text = "Tap To Begin"
        tapToStartLabel.fontSize = 100
        tapToStartLabel.fontColor = SKColor.white
        tapToStartLabel.zPosition = 1
        tapToStartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        self.addChild(tapToStartLabel)
        
    }
    
    //LOSE LIFE FUNCTION
    func loseALife(){
        livesNumber -= 1
        livesLabel.text = "Lives: \(livesNumber)"
        
        if livesNumber == 0{
            runGameOver()
        }
    }
    
    //START GAME FUNCTION
    func startGame(){
        
        currentGameState = gameState.inGame
        
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        let deleteAction = SKAction.removeFromParent()
        let deleteSequence = SKAction.sequence([fadeOutAction, deleteAction])
        tapToStartLabel.run(deleteSequence)
        
        let moveShipOntoScreenAction = SKAction.moveTo(y: self.size.height*0.2, duration: 0.5)
        let startLevelAction = SKAction.run(startNewLevel)
        let startGameSequence = SKAction.sequence([moveShipOntoScreenAction, startLevelAction])
        player.run(startGameSequence)
        
    }
    
    //ADD SCORE FUNCTION + LEVEL UP THRESHOLDS
    func addScore(){
        
        gameScore += 1
        scoreLabel.text = "score: \(gameScore)"
        
        if gameScore == 10 || gameScore == 25 || gameScore == 50{
            startNewLevel()
        }
        
    }
    
    //GAME OVER FUNCTION
    func runGameOver(){
        
        currentGameState = gameState.afterGame
        
        self.removeAllActions()
        self.enumerateChildNodes(withName: "Bullet"){
            bullet, stop in
            
            bullet.removeAllActions()
        }
        
        self.enumerateChildNodes(withName:"Enemy"){
            enemy, stop in
            enemy.removeAllActions()
        }
        
        let changeSceneAction = SKAction.run(changeScene)
        let waitToChangeScene = SKAction.wait(forDuration: 1)
        let changeSceneSequence = SKAction.sequence([waitToChangeScene, changeSceneAction])
        self.run(changeSceneSequence)
        
    }
    
    //CHANGE SCENE TO GAMEOVER SCENE
    func changeScene(){
        
        let sceneToMoveTo = GameOverScene(size: self.size)
            sceneToMoveTo.scaleMode = self.scaleMode
        let myTransition = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(sceneToMoveTo, transition: myTransition)
    }
    
    //COLLISION CODE
    func didBegin(_ contact: SKPhysicsContact) {
        
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            body1 = contact.bodyA
            body2 = contact.bodyB
        }
        else{
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        
        //PLAYER ENEMY COLLISION
        if body1.categoryBitMask == PhysicsCategories.player && body2.categoryBitMask == PhysicsCategories.Enemy{
            
            if body1.node != nil{
                spawnExplosion(spawnPosition: body1.node!.position)
            }
            
            if body2.node != nil {
            spawnExplosion(spawnPosition: body2.node!.position)
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
            runGameOver()
        }
        
        //BULLET ENEMY COLLISION
        if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Enemy{
            
            addScore()
            
            if body2.node != nil {
            spawnExplosion(spawnPosition: body2.node!.position)
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
        }
    }
    
    // EXPLOSION SPAWNER FUNCTION
    func spawnExplosion(spawnPosition: CGPoint){
        
        let explosion = SKSpriteNode(imageNamed: "Explosion")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        self.addChild(explosion)
        let scaleIn = SKAction.scale(to: 5, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        let explosionSequence = SKAction.sequence([explosionSound, scaleIn, fadeOut, delete])
        
        //MUTE EXPLOSION SOUND + EXPLOSION SEQUENCE
        if(muted == false){
            let explosionSequence = SKAction.sequence([explosionSound, scaleIn, fadeOut, delete])
            explosion.run(explosionSequence)
        }else{
            let explosionSequence = SKAction.sequence([scaleIn, fadeOut, delete])
            explosion.run(explosionSequence)
        }
    }
    
    //BULLET SPAWNER FUNCTION
    func fireBullet() {
        
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.name = "Bullet"
        bullet.setScale(1)
        bullet.position = player.position
        bullet.zPosition = 1
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.categoryBitMask = PhysicsCategories.Bullet
        bullet.physicsBody!.collisionBitMask = PhysicsCategories.None
        bullet.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(bullet)
        
        let moveBullet = SKAction.moveTo(y:self.size.height + bullet.size.height, duration: 1)
        let deleteBullet = SKAction.removeFromParent()
      
        //MUTE BULLET SOUND + BULLET SEQUENCE
        if(muted == false){
            let bulletSequence = SKAction.sequence([bulletSound, moveBullet, deleteBullet])
            bullet.run(bulletSequence)
            }else{
            let bulletSequence = SKAction.sequence([moveBullet, deleteBullet])
            bullet.run(bulletSequence)
        }
    
        
    }
   
   // ENEMY SPAWNING FUNCTION
   func spawnEnemy(){
    
        //ENEMY SPAWN AND DESPAWN LOCATION CODE
        let randomXStart = random(min: gameArea.minX, max: gameArea.maxX)
        let randomXEnd = random(min: gameArea.minX, max: gameArea.maxX)

        let startPoint = CGPoint(x: randomXStart, y: self.size.height)
        let endPoint = CGPoint(x:randomXEnd, y: -self.size.height)
    
        //ENEMY INFO
        let enemy = SKSpriteNode(imageNamed: "meteor")
        enemy.setScale(3)
        enemy.position = startPoint
        enemy.zPosition = 2
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = PhysicsCategories.Enemy
        enemy.physicsBody!.collisionBitMask = PhysicsCategories.None
        enemy.physicsBody!.contactTestBitMask = PhysicsCategories.player | PhysicsCategories.Bullet
    
        self.addChild(enemy)
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 5)
        let deleteEnemy = SKAction.removeFromParent()
        let loseALifeAction = SKAction.run(loseALife)
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy, loseALifeAction])
    
        if currentGameState == gameState.inGame{
        enemy.run(enemySequence)
        }
    
        //ENEMY ORIENTATION RANDOMIZER
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountToRotate = atan2(dy, dx)
        enemy.zRotation = amountToRotate
        
        
    }
    
    
    // LEVEL START FUNCTION
    func startNewLevel(){
        
        levelNumber += 1
        var levelDuration = TimeInterval()
        
        
        if self.action(forKey: "spawningEnemies") != nil{
            self.removeAction(forKey: "spawningEnemies")
        }
        
        //DIFFICULTY SCALING DETAILS
        switch levelNumber {
        case 1: levelDuration = 1.2
        case 2: levelDuration = 1
        case 3: levelDuration = 0.8
        case 4: levelDuration = 0.5
        default:
            levelDuration = 0.5
        }
        
        let spawn = SKAction.run(spawnEnemy)
        let waitToSpawn = SKAction.wait(forDuration: levelDuration)
        let spawnSequence = SKAction.sequence([spawn, waitToSpawn])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever, withKey: "spawningEnemies")
    }
    
    //PLAYER FIRE CONTROLS
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if currentGameState == gameState.preGame{
            startGame()
        } else if currentGameState == gameState.inGame{
            fireBullet()
        }
        
    }
    
    //PLAYER MOVEMENT CONTROLS
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches{
            
            let pointOfTouch = touch.location(in: self)
            let previousPointOfTouch = touch.previousLocation(in: self)
            
            let amountDragged = pointOfTouch.x - previousPointOfTouch.x
            
            
            
            if currentGameState == gameState.inGame{
            player.position.x += amountDragged
            }
            if player.position.x > gameArea.maxX - player.size.width/2{
                player.position.x = gameArea.maxX - player.size.width/2
            }
            if player.position.x < gameArea.minX + player.size.width/2{
                player.position.x = gameArea.minX + player.size.width/2
            }
            
        }
    }
        
}
    
  


