//
//  Ship.swift
//  SKInvaders
//
//  Created by Chase Gosingtian on 11/17/14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

import Foundation
import SpriteKit

let kShipName = "ship"
let kShipSize = CGSize(width: 30, height: 16)

class Ship : SKSpriteNode {    
    var shipHealth: Float = 1.0
    
    override init() {
        let texture = SKTexture(imageNamed: "Ship.png")
        super.init(texture: texture, color: nil, size: kShipSize)
        
        name = kShipName
        
        setupPhysics()
        assert(physicsBody != nil, "Player Ship physics body must be initialized.")
    }
    
    func setupPhysics() {
        physicsBody = SKPhysicsBody(rectangleOfSize: self.frame.size)
        physicsBody!.dynamic = true
        physicsBody!.affectedByGravity = false
        physicsBody!.mass = 0.02
        physicsBody!.categoryBitMask = kShipCategory
        physicsBody!.contactTestBitMask = 0x0
        physicsBody!.collisionBitMask = kSceneEdgeCategory
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}