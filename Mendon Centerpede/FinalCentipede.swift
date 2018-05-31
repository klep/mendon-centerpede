//
//  Centipede.swift
//  Mendon Centerpede
//
//  Created by Scott J. Kleper on 4/14/18.
//  Copyright © 2018 Boat Launch, Inc. All rights reserved.
//

import Foundation
import CoreGraphics

class FinalCentipede: Centipede {
    override func takeTurn() {
        let oldX = xPosition
        let oldY = yPosition
        let oldDirection = direction

        xPosition = oldX + direction
        yPosition = oldY
        direction = oldDirection
        
        if xPosition >= gridWidth {
            xPosition = gridWidth - 1
            yPosition = oldY - 1
            direction = -1
        }
        
        if xPosition < 0 {
            xPosition = 0
            yPosition = oldY - 1
            direction = 1
        }
        
        if grid!.hasMushroom(x: xPosition, y: yPosition) ||
            grid!.hasCentipede(x: xPosition, y: yPosition) {
            xPosition = oldX
            yPosition = oldY - 1
            direction = -oldDirection
        }
    }
    
    override func hit(at index: Int, x: Int, y: Int) {
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
}
