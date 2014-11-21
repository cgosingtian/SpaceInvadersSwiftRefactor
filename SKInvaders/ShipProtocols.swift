//
//  ShipProtocols.swift
//  SKInvaders
//
//  Created by Chase Gosingtian on 11/21/14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

import Foundation

@objc protocol ShipHealthDelegate {
    func willChangeHealth(healthChangeValue: Float)
    optional func didChangeHealth()
}

@objc protocol ShipFiringDelegate {
    func willFire()
    optional func didFire()
}