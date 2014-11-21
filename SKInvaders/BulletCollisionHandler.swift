//
//  BulletCollisionHandler.swift
//  SKInvaders
//
//  Created by Chase Gosingtian on 11/17/14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

import Foundation
import SpriteKit

// Contact Detection Bitmasks
let kInvaderCategory: UInt32 = 0x1 << 0
let kShipFiredBulletCategory: UInt32 = 0x1 << 1
let kShipCategory: UInt32 = 0x1 << 2
let kSceneEdgeCategory: UInt32 = 0x1 << 3
let kInvaderFiredBulletCategory: UInt32 = 0x1 << 4

class BulletCollisionHandler {
    
    var shipHealthDelegate:ShipHealthDelegate?
    var scoreDelegate:ScoreDelegate?
    
    class var sharedInstance : BulletCollisionHandler {
        struct Static {
            static let instance : BulletCollisionHandler = BulletCollisionHandler();
        }

        return Static.instance;
    }
    
    // TODO: Don't access GameScene methods from here!
    func handleBulletCollision(contact: SKPhysicsContact) {
        if let firstNode = contact.bodyA.node {
            if let secondNode = contact.bodyB.node {
                // Ensure you haven't already handled this contact and removed its nodes
                if (firstNode.parent == nil || secondNode.parent == nil) {
                    return
                }
                
                var nodeNames = [firstNode.name!, secondNode.name!] as NSArray
                
                if (nodeNames.containsObject(kShipName) && nodeNames.containsObject(kInvaderFiredBulletName)) {
                    var invaderBullet : Bullet
                    var playerShip : Ship
                    
                    if (firstNode.name == kShipName) {
                        playerShip = firstNode as Ship
                        invaderBullet = secondNode as Bullet
                    } else {
                        invaderBullet = firstNode as Bullet
                        playerShip = secondNode as Ship
                    }
                    
                    shipHealthDelegate?.willChangeHealth(-invaderBullet.kInvaderBulletDamage)
                    
                    // TODO: Delegate the node removals?
                    if playerShip.shipHealth <= 0.0 {
                        firstNode.removeFromParent()
                        secondNode.removeFromParent()
                    } else {
                        playerShip.alpha = CGFloat(playerShip.shipHealth)
                        
                        if firstNode == playerShip {
                            secondNode.removeFromParent()
                        } else {
                            firstNode.removeFromParent()
                        }
                    }
                } else if (nodeNames.containsObject(kInvaderName) && nodeNames.containsObject(kShipFiredBulletName)) {
                    var playerBullet : Bullet;
                    
                    if (firstNode.name == kInvaderName) {
                        playerBullet = secondNode as Bullet
                    } else {
                        playerBullet = firstNode as Bullet
                    }
                    
                    if let firstCollidable = firstNode as? CollisionDelegate {
                        firstCollidable.willCollide()
                    }
                    
                    if let secondCollidable = secondNode as? CollisionDelegate {
                        secondCollidable.willCollide()
                    }
                    
                    scoreDelegate?.willUpdateScore(100)
                }
            } else {
                return
            }
        } else {
            return
        }
    }
}