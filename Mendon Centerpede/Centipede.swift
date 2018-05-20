//
//  Centipede.swift
//  Mendon Centerpede
//
//  Created by Scott J. Kleper on 4/14/18.
//  Copyright © 2018 Boat Launch, Inc. All rights reserved.
//

import Foundation
import CoreGraphics

class Centipede {
    let gridWidth: Int
    let gridHeight: Int
    var bodyCount: Int
    var xPosition: Int
    var yPosition: Int
    weak var grid: Grid?
    var didBumpIntoMushroom = false

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
        let oldX = xPosition
        let oldY = yPosition
        let oldDirection = direction

        var newX = oldX + direction
        var newY = oldY
        var newDirection = oldDirection
        
        if newX >= gridWidth {
            newX = gridWidth - 1
            newY = oldY - 1
            newDirection = -1
        }
        
        if newX < 0 {
            newX = 0
            newY = oldY - 1
            newDirection = 1
        }
        
        if grid!.hasMushroom(x: newX, y: newY) ||
            grid!.hasCentipede(x: newX, y: newY) {
            newX = oldX
            newY = oldY - 1
            newDirection = -oldDirection
        }
        
        xPosition = newX
        yPosition = newY
        direction = newDirection
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
            grid.addCentipede(x: x - direction - direction,
                              y: y, direction: self.direction,
                              bodyCount: originalBodyCount - bodyCount - 1)
        }
        
        grid.speed = grid.speed * 1.1
        grid.addMushroom(x: x, y: y)
        
        print("A centipede of length \(originalBodyCount) was hit at index \(index) (\(x), \(y)), making the old one length \(bodyCount) and the new one \(newCentipedeBodyCount)")
    }
    
    func bumpedIntoMushroom() {
        yPosition -= 1
        xPosition += direction
        direction = -direction
        
        // todo: could verify that direction doesn't send it off the grid here, but might be too complex for kids
    }
}
