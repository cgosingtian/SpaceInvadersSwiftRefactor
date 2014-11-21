//
//  GameScene.swift
//  SKInvaders
//
//  Created by Riccardo D'Antoni on 15/07/14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

import SpriteKit

let kInvaderGridSpacing = CGSize(width:12, height:12)
let kInvaderRowCount = 6
let kInvaderColCount = 6

class GameScene: SKScene, SKPhysicsContactDelegate, ShipHealthDelegate, ScoreDelegate { // IMPORTANT - SKPhysicsContactDelegate handles contacts
    
    var contentCreated = false
    
    // Scene Objects
    var playerController = PlayerController()
    var invaderController = InvaderController()
    
    // Game Data
    var score: Int = 0
    
    // HUD
    let kScoreHudName = "scoreHud"
    let kHealthHudName = "healthHud"
    
    // Physics
    var contactQueue = Array<SKPhysicsContact>()
    
    // End Game
    let kMinInvaderBottomHeight: Float = 1.0
    var gameEnding: Bool = false
  
    // Object Lifecycle Management
  
    // MARK: Scene Setup and Content Creation
    override func didMoveToView(view: SKView) {
        if (!self.contentCreated) {
            self.createContent()
            self.contentCreated = true
            self.playerController.motionManager.startAccelerometerUpdates()
            
            // PlayerController delegates HUD health updating to GameScene
            self.playerController.shipHealthDelegate = self
            // BulletCollisionHandler delegates ship damage application to PlayerController
            BulletCollisionHandler.sharedInstance.shipHealthDelegate = self.playerController
            
            userInteractionEnabled = true
            physicsWorld.contactDelegate = self
        }
    }
  
    func createContent() {
        hidden = true
        // We're actually setting self.physicsBody here
        physicsBody = SKPhysicsBody(edgeLoopFromRect: frame)
    
        physicsBody!.categoryBitMask = kSceneEdgeCategory
    
        addInvadersToInvadersNode()
        addChild(self.invaderController)
    
        // black space color
        self.backgroundColor = SKColor.blackColor()
    
        addShipToPlayerNode()
        addChild(self.playerController)
        
        setupHud()
        
        // Add the BulletController - this is where bullet nodes appear
        addChild(BulletController.sharedInstance)
    }
    
    func addShipToPlayerNode() {
        // Why is y set to half of the ship's height?
        // Each sprite has a default "center" at 0.5,0.5.
        // This means that when the sprite is placed, half of the
        // sprite appears above that point, and half below.
        // The same applies for its left and right sides.
        // Changing the sprite's position essentially changes
        // how the parts of the sprite are shown.
        let startingPoint: CGPoint = CGPoint(x: size.width / 2.0, y: kShipSize.height / 2.0)
        self.playerController.placeShipAtPoint(startingPoint)
    }
    
    func addInvadersToInvadersNode() {
        let baseOrigin = CGPoint(x:size.width / 3, y:180)
        for var row = 1; row <= kInvaderRowCount; row++ {
            var invaderType: InvaderType
            if row % 3 == 0 {
                invaderType = .A
            } else if row % 3 == 1 {
                invaderType = .B
            } else {
                invaderType = .C
            }
            
            var invader = Invader(invaderType: invaderType)
            
            let invaderPositionY = CGFloat(row) * (invader.size.height * 2) + baseOrigin.y
            var invaderPosition = CGPoint(x:baseOrigin.x, y:invaderPositionY)
            
            for var col = 1; col <= kInvaderColCount; col++ {
                invader.position = invaderPosition
                self.invaderController.addChild(invader)
                
                invaderPosition = CGPoint(x: invaderPosition.x + invader.size.width + kInvaderGridSpacing.width, y: invaderPositionY)

                invader = Invader(invaderType: invaderType)
            }
        }
    }
    
    func setupHud() {
        let scoreLabel = SKLabelNode(fontNamed: "Courier")
        scoreLabel.name = kScoreHudName
        scoreLabel.fontSize = 25
        scoreLabel.fontColor = SKColor.greenColor()
        scoreLabel.position = CGPoint(x: frame.size.width / 2, y: size.height - (40 + scoreLabel.frame.size.height/2))
       
        addChild(scoreLabel)
        updateScoreLabel()
        
        let healthLabel = SKLabelNode(fontNamed: "Courier")
        
        healthLabel.name = kHealthHudName
        healthLabel.fontSize = 25
        healthLabel.fontColor = SKColor.redColor()
        healthLabel.position = CGPoint(x: frame.size.width / 2, y: size.height - (80 + healthLabel.frame.size.height/2))
        
        addChild(healthLabel)
        updateHealthLabel()
    }
  
  // MARK: Scene Update
  override func update(currentTime: CFTimeInterval) {
    if (hidden) {
        hidden = false
    }
    /* Called before each frame is rendered */

    processContactsForUpdate(currentTime)
    self.playerController.processUserTapsForUpdate(currentTime)
    self.invaderController.moveInvadersForUpdate(currentTime)
//    self.playerController.processUserMotionForUpdate(currentTime)
    self.invaderController.fireInvaderBulletsForUpdate(currentTime)
    
    if self.isGameOver() {
        self.endGame()
    }
  }
  
  
  // MARK: Scene Update Helpers
    
    
    func processContactsForUpdate(currentTime: CFTimeInterval) {
        
        for contact in self.contactQueue {
            self.handleContact(contact)
            
            if let index = (self.contactQueue as NSArray).indexOfObject(contact) as Int? {
                self.contactQueue.removeAtIndex(index)
            }
        }
    }
    
  // MARK: User Tap Helpers
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        // Intentional no-op
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent)  {
        // Intentional no-op
    }
    
    override func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {
        // Intentional no-op
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent)  {
        
        if let touch : AnyObject = touches.anyObject() {
            
//            if (touch.tapCount == 1) {
            
                // add a tap to the queue
                self.playerController.tapQueue.append(1)
//            }
        }
    }
  
  // MARK: HUD Helpers
    func adjustScoreBy(points: Int) {
        
        self.score += points
        
        updateScoreLabel()
    }
    
    // MARK: Health and Score Delegate Methods
    func willChangeHealth(healthChangeValue: Float) {
        didChangeHealth()
    }
    func didChangeHealth() {
        runAction(SKAction.playSoundFileNamed("ShipHit.wav", waitForCompletion: false))
        updateHealthLabel()
    }
    
    func willUpdateScore(additionalScore: Int) {
        self.score += additionalScore
        
        didUpdateScore()
    }
    
    func didUpdateScore() {
        updateScoreLabel()
    }
    
    func updateHealthLabel() {
        let health = self.childNodeWithName(kHealthHudName) as SKLabelNode
        health.text = String(format: "Health: %.1f%%", self.playerController.shipHealth * 100)
    }
    
    func updateScoreLabel() {
        let score = self.childNodeWithName(kScoreHudName) as SKLabelNode
        score.text = String(format: "Score: %04u", self.score)
    }
  
  // MARK: Physics Contact Helpers
    func didBeginContact(contact: SKPhysicsContact!) {
        if contact != nil {
            self.contactQueue.append(contact)
        }
    }
    
    func handleContact(contact: SKPhysicsContact) {
        let bulletCollisionHandler = BulletCollisionHandler.sharedInstance
        
        bulletCollisionHandler.handleBulletCollision(contact)
    }
  
  // MARK: Game End Helpers
    func isGameOver() -> Bool {
        if (!self.gameEnding) {
            // 1 - We check if this is nil later; if nil, no more invaders
            let invader = self.invaderController.childNodeWithName(kInvaderName)
        
            // 2
            var invaderTooLow = false
        
            self.invaderController.enumerateChildNodesWithName(kInvaderName) {
                node, stop in
            
                if (Float(CGRectGetMinY(node.frame)) <= self.kMinInvaderBottomHeight)   {
                    invaderTooLow = true
                    stop.memory = true
                }
            }
        
            // 3 - Like in #1, we check if the ship is still alive
            let ship = self.playerController.childNodeWithName(kShipName)
    
            return invader == nil || invaderTooLow || ship == nil
        }
        return false
    }
    
    func endGame() {
        // 1
        if !self.gameEnding {
            
            self.gameEnding = true
            
            // 2
            self.playerController.motionManager.stopAccelerometerUpdates()
            
            // 3
            let gameOverScene: GameOverScene = GameOverScene(size: self.size)
            
            view!.presentScene(gameOverScene, transition: SKTransition.doorsOpenHorizontalWithDuration(1.0))
        }
    }
}
