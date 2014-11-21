//
//  Invaders.swift
//  SKInvaders
//
//  Created by Chase Gosingtian on 11/17/14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

import Foundation
import SpriteKit

enum InvaderType {
    case A
    case B
    case C
}

let kInvaderName = "invader"

class Invader : SKSpriteNode, CollisionDelegate {
    
    let kInvaderSize = CGSize(width:24, height:16)
    var invaderType = InvaderType.A
    let kInvaderAnimationSpeed = 1.0
    
    override init() {
        super.init(texture: nil, color: nil, size: kInvaderSize)
        
        let invaderTextures = loadInvaderTexturesOfType(invaderType)
        
        texture = invaderTextures[0]
        name = kInvaderName
        
        setupAnimation(invaderTextures, timePerFrame: kInvaderAnimationSpeed)
        setupPhysics()
    }
    
    init(invaderType: InvaderType!) {
        self.invaderType = invaderType;
        super.init(texture: nil, color: nil, size: kInvaderSize)
        
        let invaderTextures = loadInvaderTexturesOfType(invaderType)
        
        texture = invaderTextures[0]
        name = kInvaderName
        
        setupAnimation(invaderTextures, timePerFrame: kInvaderAnimationSpeed)
        setupPhysics()
        assert(physicsBody != nil, "Invader physics body must be initialized.")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupAnimation(texturesArray: [SKTexture], timePerFrame: NSTimeInterval) {
        self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(texturesArray, timePerFrame: timePerFrame)))
    }
    
    func setupPhysics() {
        physicsBody = SKPhysicsBody(rectangleOfSize: self.frame.size)
        physicsBody!.dynamic = false
        physicsBody!.categoryBitMask = kInvaderCategory
        physicsBody!.contactTestBitMask = 0x0
        physicsBody!.collisionBitMask = 0x0
    }
    
    func disablePhysics() {
        physicsBody?.categoryBitMask = 0x0
        physicsBody?.contactTestBitMask = 0x0
        physicsBody?.collisionBitMask = 0x0
    }
    
    func loadInvaderTexturesOfType(invaderType: InvaderType) -> Array<SKTexture> {
        
        var prefix: String
        
        switch(invaderType) {
        case .A:
            prefix = "InvaderA"
        case .B:
            prefix = "InvaderB"
        case .C:
            prefix = "InvaderC"
        default:
            prefix = "InvaderC"
        }
        
        // 1 - note that this returns an array
        return [SKTexture(imageNamed: String(format: "%@_00.png", prefix)),
            SKTexture(imageNamed: String(format: "%@_01.png", prefix))]
    }
    
    // Mark: CollisionDelegate Methods
    func willCollide() {
        didCollide()
    }
    
    func didCollide() {
        disablePhysics()
        let fadeAction = SKAction.fadeAlphaTo(0.0, duration: 1.5)
        let soundAction = SKAction.playSoundFileNamed("InvaderHit.wav", waitForCompletion: false)
        let scaleAction = SKAction.scaleBy(2.0, duration: 1.0)
        
        let deathActionGroup = SKAction.group([soundAction, scaleAction, fadeAction])
        
        let deathActionSequence = SKAction.sequence([[deathActionGroup], SKAction.removeFromParent()])
        
        runAction(deathActionSequence)
    }
}