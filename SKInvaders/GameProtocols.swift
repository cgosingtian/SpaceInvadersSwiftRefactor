//
//  GameProtocols.swift
//  SKInvaders
//
//  Created by Chase Gosingtian on 11/21/14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

import Foundation

@objc protocol ScoreDelegate {
    func willUpdateScore(additionalScore: Int)
    optional func didUpdateScore()
}