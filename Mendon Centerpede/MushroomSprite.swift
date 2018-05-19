//
//  MushroomSprite.swift
//  Mendon Centerpede
//
//  Created by Scott J. Kleper on 5/15/18.
//  Copyright © 2018 Boat Launch, Inc. All rights reserved.
//

import SpriteKit

class MushroomSprite: GridSprite {
    var strength = 4
    
    func hit() {
        strength -= 1
        if (strength <= 0) {
            removeFromParent()
        }
    }
}
