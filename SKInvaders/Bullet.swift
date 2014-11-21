//
//  Bullet.swift
//  SKInvaders
//
//  Created by Chase Gosingtian on 11/17/14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

import Foundation
import SpriteKit

enum BulletType {
    case ShipFiredBulletType
    case InvaderFiredBulletType
}

let kShipFiredBulletName = "shipFiredBullet"
let kInvaderFiredBulletName = "invaderFiredBullet"

class Bullet : SKSpriteNode, CollisionDelegate {
    let kBulletSize = CGSizeMake(4, 8)
    let kInvaderBulletDamage = 0.334 as Float
    var isInvaderFired = false
    
    init(bulletType: BulletType) {
        switch (bulletType) {
        case .ShipFiredBulletType:
            super.init(texture: nil, color: SKColor.greenColor(), size: kBulletSize)
            name = kShipFiredBulletName
            break;
        case .InvaderFiredBulletType:
            super.init(texture: nil, color: SKColor.magentaColor(), size: kBulletSize)
            name = kInvaderFiredBulletName
            self.isInvaderFired = true
            break;
        }
        
        setupPhysics()
        assert(physicsBody != nil, "Bullet physics need to be initialized.")
    }
    
    func setupPhysics() {
        physicsBody = SKPhysicsBody(rectangleOfSize: frame.size)
        physicsBody!.dynamic = true
        physicsBody!.affectedByGravity = false
        physicsBody!.categoryBitMask = kShipFiredBulletCategory
        physicsBody!.collisionBitMask = 0x0
        
        if (self.isInvaderFired) {
            physicsBody!.contactTestBitMask = kShipCategory
        } else {
            physicsBody!.contactTestBitMask = kInvaderCategory
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Mark: CollisionDelegate Methods
    func willCollide() {
        didCollide()
    }
    func didCollide() {
        removeFromParent()
    }
}
