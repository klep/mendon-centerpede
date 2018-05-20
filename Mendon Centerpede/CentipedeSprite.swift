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
    static let texture = SKTexture(imageNamed: "head")
        
    init() {
        super.init(texture: CentipedeSprite.texture, color: UIColor.black,
                   size: CentipedeSprite.texture.size())
        colorBlendFactor = 1.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
