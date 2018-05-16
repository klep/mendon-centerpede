//
//  Centipede.swift
//  Mendon Centerpede
//
//  Created by Scott J. Kleper on 4/14/18.
//  Copyright © 2018 Boat Launch, Inc. All rights reserved.
//

import Foundation
import CoreGraphics

class Centipede: Sprite {
    let gridWidth: Int
    let gridHeight: Int
    var bodyCount: Int
    var xPosition: Int
    var yPosition: Int
    weak var grid: Grid?

    init(bodyCount: Int, gridWidth: Int, gridHeight: Int, startX: Int, startY: Int, grid: Grid) {
        self.gridWidth = gridWidth
        self.gridHeight = gridHeight
        self.bodyCount = bodyCount
        self.xPosition = startX
        self.yPosition = startY
        self.grid = grid
    }
    
    var direction = 1
//    var speed = 2
    
    func takeTurn() {
        let oldXPosition = xPosition

        xPosition = oldXPosition + direction
        
        if xPosition >= gridWidth {
            xPosition = gridWidth - 1
            yPosition -= 1
            direction = -1
        }
        
        if xPosition < 0 {
            xPosition = 0
            yPosition -= 1
            direction = 1
        }
    }
    
    func hit(at index: Int, x: Int, y: Int) {
        guard let grid = grid else { return }
        
        let originalBodyCount = bodyCount
        bodyCount = index
        if bodyCount <= 0 {
            grid.remove(centipede: self)
        }
        
        let newCentipedeBodyCount = originalBodyCount - bodyCount - 1
        if newCentipedeBodyCount > 0 {
            grid.addCentipede(x: x - 1, y: y, direction: self.direction, bodyCount: originalBodyCount - bodyCount - 1)
        }
        
        grid.speed = grid.speed * 1.2
        
        print("A centipede of length \(originalBodyCount) was hit at index \(index) (\(x), \(y)), making the old one length \(bodyCount) and the new one \(newCentipedeBodyCount)")
    }
}
