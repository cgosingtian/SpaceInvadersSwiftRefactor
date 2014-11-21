//
//  BulletProtocols.swift
//  SKInvaders
//
//  Created by Chase Gosingtian on 11/21/14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

import Foundation

@objc protocol CollisionDelegate {
    func willCollide()
    optional func didCollide()
}

@objc protocol CanFireBullets {
    var bulletController: BulletController { get }
}