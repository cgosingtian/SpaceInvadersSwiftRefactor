//
//  InvaderDirectionController.swift
//  SKInvaders
//
//  Created by Chase Gosingtian on 11/20/14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

import Foundation
import SpriteKit

enum InvaderMovementDirection {
    case Right
    case Left
    case DownThenRight
    case DownThenLeft
    case None
}

class InvaderController : SKNode, CanFireBullets {
    
    let kInvaderMoveDistance = 2.5 as CGFloat
    var invaderMovementDirection: InvaderMovementDirection = .Right
    var timeOfLastMove: CFTimeInterval = 0.0
    var timePerMove: CFTimeInterval = 0.25
    
    // CanFireBullets Protocol Required Variables
    var bulletController: BulletController = BulletController.sharedInstance
    
    func determineInvaderMovementDirection() {
        
        var proposedMovementDirection: InvaderMovementDirection = self.invaderMovementDirection
        
        enumerateChildNodesWithName(kInvaderName) { node, stop in
            switch self.invaderMovementDirection {
            case .Right:
                if (CGRectGetMaxX(node.frame) >= node.scene!.size.width - self.kInvaderMoveDistance) {
                    proposedMovementDirection = .DownThenLeft
                    stop.memory = true
                }
                break
            case .Left:
                if (CGRectGetMinX(node.frame) <= self.kInvaderMoveDistance) {
                    proposedMovementDirection = .DownThenRight
                    stop.memory = true
                }
                break
            case .DownThenLeft:
                proposedMovementDirection = .Left
                stop.memory = true
                break
            case .DownThenRight:
                proposedMovementDirection = .Right
                stop.memory = true
                break
            default:
                break
            }
        }
        
        if (proposedMovementDirection != self.invaderMovementDirection) {
            self.invaderMovementDirection = proposedMovementDirection
        }
    }
    
    func adjustInvaderMovementToTimePerMove(newTimerPerMove: CFTimeInterval) {
        // 1
        if newTimerPerMove <= 0 {
            return
        }
        
        // 2 - Setting a node's speed makes it move faster / slower
        let ratio: CGFloat = CGFloat(self.timePerMove / newTimerPerMove)
        self.timePerMove = newTimerPerMove
        
        speed = speed * ratio
    }
    
    func moveInvadersForUpdate(currentTime: CFTimeInterval) {
        
        if (currentTime - timeOfLastMove < timePerMove) {
            return
        }
        
        self.determineInvaderMovementDirection()
        
        enumerateChildNodesWithName(kInvaderName) {
            node, stop in
            let invaderX : CGFloat = node.position.x
            let invaderY : CGFloat = node.position.y

            switch self.invaderMovementDirection {
            case .Right:
                node.position = CGPoint(x: invaderX + self.kInvaderMoveDistance, y: invaderY)
            case .Left:
                node.position = CGPoint(x: invaderX - self.kInvaderMoveDistance, y: invaderY)
            case .DownThenLeft, .DownThenRight:
                node.position = CGPoint(x: invaderX, y: invaderY - self.kInvaderMoveDistance*4)
            case .None:
                break
            default:
                break
        }
        
        self.timeOfLastMove = currentTime
        }
    }
    
    func fireInvaderBulletsForUpdate(currentTime: CFTimeInterval) {
        
        let existingBullet = self.bulletController.childNodeWithName(kInvaderFiredBulletName)
        
        // 1
        if existingBullet == nil {
            
            var allInvaders = Array<SKNode>()
            
            // 2
            enumerateChildNodesWithName(kInvaderName) {
                node, stop in
                
                allInvaders.append(node)
            }
            
            if allInvaders.count > 0 {
                
                // 3
                let allInvadersIndex = Int(arc4random_uniform(UInt32(allInvaders.count)))
                
                let invader = allInvaders[allInvadersIndex]
                
                // 4
                var bullet = Bullet(bulletType: .InvaderFiredBulletType)
                bullet.position = CGPointMake(invader.position.x, invader.position.y - invader.frame.size.height / 2 + bullet.frame.size.height / 2)
                
                // 5
                let bulletDestination = CGPointMake(invader.position.x, -(bullet.frame.size.height / 2))
                
                // 6
                self.bulletController.fireBullet(bullet, toDestination: bulletDestination, withDuration: 2.0, andSoundFileName: "InvaderBullet.wav")
            }
        }
    }
}
