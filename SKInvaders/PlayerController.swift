//
//  PlayerController.swift
//  SKInvaders
//
//  Created by Chase Gosingtian on 11/21/14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

import Foundation
import SpriteKit
import CoreMotion

class PlayerController : SKNode, ShipHealthDelegate, CanFireBullets {

    var shipHealth : Float {
        var health : Float = 0.0
        self.enumerateChildNodesWithName(kShipName) {
            node, stop in
            if let playerShip = node as? Ship {
                health = playerShip.shipHealth
            }
        }
        return health
    }
    
    // CanFireBullets Protocol Required Variables
    var bulletController: BulletController = BulletController.sharedInstance
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var shipHealthDelegate: ShipHealthDelegate?
    
    let motionManager: CMMotionManager = CMMotionManager()
    var tapQueue: Array<Int> = []
    let kFlatAccelerationRange = 0.2
    let kAccelerationForce = 40.0
    
    func placeShipAtPoint(startingPoint: CGPoint) {
        if let playerShip = childNodeWithName(kShipName) as? Ship {
            playerShip.position = startingPoint
        } else {
            var playerShip = Ship()
            playerShip.position = startingPoint
            addChild(playerShip)
        }
    }
    
    // MARK: Player Control Methods
    
    func processUserMotionForUpdate(currentTime: CFTimeInterval) {
        
        // 1 - Using a conditional downcast (as?) here since the ship can be destroyed
        // App will crash otherwise
        if let ship = childNodeWithName(kShipName) as? SKSpriteNode // IMPORTANT
        {
            // 2
            if let data = motionManager.accelerometerData {
                // 3
                if (fabs(data.acceleration.x) > kFlatAccelerationRange) {
                    // 4 How do you move the ship?
                    ship.physicsBody!.applyForce(CGVectorMake(CGFloat(kAccelerationForce) * CGFloat(data.acceleration.x), 0))
                }
            }
        }
    }
    
    func processUserTapsForUpdate(currentTime: CFTimeInterval) {
        // 1
        for tapCount in self.tapQueue {
            //            if tapCount == 1 {
            // 2
            self.fireShipBullets()
            //            }
            // 3
            self.tapQueue.removeAtIndex(0)
        }
    }
    
    // MARK: Bullet Firing Methods
    func fireShipBullets() {
        
        let existingBullet = self.bulletController.childNodeWithName(kShipFiredBulletName)
        
        if existingBullet == nil {
            // Fire only if the ship is alive
            if let ship = self.childNodeWithName(kShipName) {
                var bullet = Bullet(bulletType: .ShipFiredBulletType)
                
                bullet.position = CGPointMake(ship.position.x, ship.position.y + ship.frame.size.height - bullet.frame.size.height / 2)
                
                var maxHeight = bulletController.displayFrame.size.height - ship.position.y;
                println("\(bulletController.displayFrame.size.height)")
                
                let bulletDestination = CGPointMake(ship.position.x, maxHeight + bullet.frame.size.height / 2)
                
                self.bulletController.fireBullet(bullet, toDestination: bulletDestination, withDuration: 1.0, andSoundFileName: "ShipBullet.wav")
            }
        }
    }
    
    // MARK: ShipHealthDelegate Methods
    
    func willChangeHealth(healthChangeValue: Float) {
        adjustShipHealthBy(healthChangeValue)
    }
    
    func didChangeHealth() {
        return // do nothing
    }
    
    func adjustShipHealthBy(healthAdjustment: Float) {
        if let ship = childNodeWithName(kShipName) as? Ship // IMPORTANT
        {
            ship.shipHealth = max(ship.shipHealth + healthAdjustment, 0)
            shipHealthDelegate?.didChangeHealth!()
        }
    }
}
