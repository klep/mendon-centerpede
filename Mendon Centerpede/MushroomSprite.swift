//
//  MushroomSprite.swift
//  Mendon Centerpede
//
//  Created by Scott J. Kleper on 5/15/18.
//  Copyright © 2018 Boat Launch, Inc. All rights reserved.
//

import SpriteKit

class MushroomSprite: GridSprite {
    static let texture = SKTexture(imageNamed: "mushroom")
    
    static let colorCycle = [UIColor.white.withAlphaComponent(0.7),
                             UIColor(red: 255/255, green: 190/255, blue: 64/255, alpha: 1),
                             UIColor(red: 227/255, green: 77/255, blue: 27/255, alpha: 1),
                             UIColor.orange]

    var strength = 4

    init() {
        super.init(texture: MushroomSprite.texture, color: MushroomSprite.colorCycle[strength - 1],
                   size: MushroomSprite.texture.size())
        colorBlendFactor = 1.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func hit() {
        strength -= 1
        if (strength <= 0) {
            removeFromParent()
        } else {
            color = MushroomSprite.colorCycle[strength - 1]
        }
    }
}
