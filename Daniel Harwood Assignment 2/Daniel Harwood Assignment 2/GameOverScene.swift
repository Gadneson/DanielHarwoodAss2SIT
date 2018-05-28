//
//  GameOverScene.swift
//  Daniel Harwood Assignment 2
//
//  Created by Daniel Harwood on 28/5/18.
//  Copyright © 2018 Deakin. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene{
    
    //BUTTON DECLARATIONS
    let restartLabel = SKLabelNode(fontNamed: "Arial")
    let redLabel = SKLabelNode(fontNamed: "Arial")
    let blueLabel = SKLabelNode(fontNamed: "Arial")
    let greenLabel = SKLabelNode(fontNamed: "Arial")
    
    
    override func didMove(to view: SKView){
        
        //SHIP COLOR POSITIONING CODE
        let screenSlice = self.size.width / 4
       
        //GAME OVER TEXT
        let gameOverLabel = SKLabelNode(fontNamed: "Arial")
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 200
        gameOverLabel.fontColor = SKColor.white
        gameOverLabel.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.7)
        gameOverLabel.zPosition = 1
        self.addChild(gameOverLabel)
        
        //GAME SCORE LABEL
        let scoreLabel = SKLabelNode(fontNamed: "Arial")
        scoreLabel.text = "score: \(gameScore)"
        scoreLabel.fontSize = 125
        scoreLabel.fontColor = SKColor.white
        scoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.55)
        scoreLabel.zPosition = 1
        self.addChild(scoreLabel)
        
        let defaults = UserDefaults()
        var highScoreNumber = defaults.integer(forKey: "highScoreSaved")
        
        //HIGH SCORE TEST
        if gameScore > highScoreNumber{
            highScoreNumber = gameScore
            defaults.set(highScoreNumber, forKey: "highScoreSaved")
        }
        
        //HIGH SCORE COUNTER
        let highScoreLabel = SKLabelNode(fontNamed: "Arial")
        highScoreLabel.text = "High Score:  \(highScoreNumber)"
        highScoreLabel.fontSize = 125
        highScoreLabel.fontColor = SKColor.white
        highScoreLabel.zPosition = 1
        highScoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.45)
        self.addChild(highScoreLabel)
        
        //RESTART BUTTON
        restartLabel.text = "Restart"
        restartLabel.fontSize = 90
        restartLabel.fontColor = SKColor.white
        restartLabel.zPosition = 1
        restartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.3)
        self.addChild(restartLabel)
        
        //RED SHIP BUTTON (DEFAULT)
        redLabel.text = "Red Ship"
        redLabel.fontSize = 55
        redLabel.fontColor = SKColor.red
        redLabel.zPosition = 1
        redLabel.position = CGPoint(x: screenSlice * 1, y: self.size.height*0.2)
        self.addChild(redLabel)
        
        //BLUE SHIP BUTTON
        blueLabel.text = "Blue Ship"
        blueLabel.fontSize = 55
        blueLabel.fontColor = SKColor.blue
        blueLabel.zPosition = 1
        blueLabel.position = CGPoint(x: screenSlice * 2, y: self.size.height*0.2)
        self.addChild(blueLabel)
        
        //GREEN SHIP BUTTON
        greenLabel.text = "Green Ship"
        greenLabel.fontSize = 55
        greenLabel.fontColor = SKColor.green
        greenLabel.zPosition = 1
        greenLabel.position = CGPoint(x: screenSlice * 3, y: self.size.height*0.2)
        self.addChild(greenLabel)
        
        //MUTE BUTTON
        muteLabel.text = "Mute"
        muteLabel.fontSize = 55
        muteLabel.fontColor = SKColor.white
        muteLabel.zPosition = 1
        muteLabel.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.9)
        self.addChild(muteLabel)
        
        
        
    }
    
    //ON TOUCH CODE ACTIONS
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            let pointOfTouch = touch.location(in: self)
            
            //RESTART GAME
            if restartLabel.contains(pointOfTouch){
                let sceneToMoveTo = GameScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                let myTransition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(sceneToMoveTo, transition: myTransition)
            }
            
            //COLOR SELECTION OPTIONS
            if redLabel.contains(pointOfTouch){
                player = SKSpriteNode(imageNamed: "RedShip")
            }
            if blueLabel.contains(pointOfTouch){
                player = SKSpriteNode(imageNamed: "BlueShip")
            }
            if greenLabel.contains(pointOfTouch){
                player = SKSpriteNode(imageNamed: "GreenShip")
            }
            
            //MUTE SOUNDS CODE
            if muteLabel.contains(pointOfTouch){
                
                if(muted == false){
                    muted = true
                }else{
                    muted = false
                }
            
        }
    }
    
    }
}
