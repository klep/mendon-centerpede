//
//  CentipedeSprite.swift
//  Mendon Centerpede
//
//  Created by Scott J. Kleper on 4/15/18.
//  Copyright © 2018 Boat Launch, Inc. All rights reserved.
//

import SpriteKit

class CentipedeSprite: GridSprite
{
    static let headTexture = SKTexture(imageNamed: "head")
    static let bodyTexture = SKTexture(imageNamed: "body")
    
    var isHead = false {
        didSet {
            if isHead != oldValue {
                self.texture = isHead ? CentipedeSprite.headTexture : CentipedeSprite.bodyTexture
            }
        }
    }
        
    init() {
        super.init(texture: CentipedeSprite.bodyTexture, color: UIColor.black,
                   size: CentipedeSprite.bodyTexture.size())
        colorBlendFactor = 1.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
