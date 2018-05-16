//
//  MushroomSprite.swift
//  Mendon Centerpede
//
//  Created by Scott J. Kleper on 5/15/18.
//  Copyright © 2018 Boat Launch, Inc. All rights reserved.
//

import SpriteKit

class MushroomSprite: SKSpriteNode {
    init() {
        let texture = SKTexture(imageNamed: "mushroom")
        super.init(texture: texture, color: UIColor.white, size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
