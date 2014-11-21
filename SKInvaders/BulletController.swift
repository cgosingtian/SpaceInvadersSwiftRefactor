//
//  BulletController.swift
//  SKInvaders
//
//  Created by Chase Gosingtian on 11/21/14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

import Foundation
import SpriteKit

class BulletController : SKNode {
    
    var displayFrame: CGRect {
        if let parentScene = scene {
            return parentScene.frame
        } else {
            return CGRectZero
        }
    }
    
    class var sharedInstance : BulletController {
        struct Static {
            static let instance : BulletController = BulletController();
        }
        
        return Static.instance;
    }
    
    func fireBullet(bullet: SKNode, toDestination destination:CGPoint, withDuration duration:CFTimeInterval, andSoundFileName soundName: String) {
        
        let bulletAction = SKAction.sequence([
            SKAction.moveTo(destination, duration: duration),
            SKAction.waitForDuration(3.0/60.0),
            SKAction.removeFromParent()
            ]) // IMPORTANT
        
        let soundAction = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        
        // IMPORTANT - note that "group" = simultaneous, whereas "sequence" = sequential
        bullet.runAction(SKAction.group([bulletAction, soundAction]))
        
        addChild(bullet)
    }
}