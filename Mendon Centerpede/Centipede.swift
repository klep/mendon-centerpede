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
    // Properties

    // Grid Position
    var xPosition: Int
    var yPosition: Int

    // 1 means ->
    // -1 means <-
    var direction = 1

    var color: UIColor

    // Total size of the grid
    let gridWidth: Int
    let gridHeight: Int

    // How many sections this centipede has (in addition to the head)
    var bodyCount: Int

    weak var grid: Grid?

    init(bodyCount: Int, gridWidth: Int, gridHeight: Int, startX: Int, startY: Int, grid: Grid) {
        self.gridWidth = gridWidth
        self.gridHeight = gridHeight
        self.bodyCount = bodyCount
        self.xPosition = startX
        self.yPosition = startY
        self.grid = grid
        self.color = .black
    }
    
    func takeTurn() {
        let oldX = xPosition
        let oldY = yPosition
        let oldDirection = direction

        var newX = oldX + direction
        var newY = oldY
        var newDirection = oldDirection
        
        xPosition = newX
        yPosition = newY
        direction = newDirection
    }
    
    func hit(at index: Int, x: Int, y: Int) {
        // TODO
    }
    
    func bumpedIntoMushroom() {
        // TODO
    }
}
