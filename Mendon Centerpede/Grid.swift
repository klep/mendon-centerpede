//
//  Grid.swift
//  Mendon Centerpede
//
//  Created by Scott J. Kleper on 4/14/18.
//  Copyright © 2018 Boat Launch, Inc. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
import GameplayKit

protocol Sprite {
    
}

struct SpriteMove {
    
}
class Grid {
    let width: CGFloat
    let height: CGFloat
    let spaceX: CGFloat
    let spaceY: CGFloat
    let xCount = 20
    let yCount = 30
    
    struct CentipedeModel {
        init(centipede: Centipede, sprites: [CentipedeSprite]) {
            self.centipede = centipede
            self.sprites = sprites
        }
        
        var centipede: Centipede
        var sprites: [CentipedeSprite]
    }

    weak var scene: SKScene?
    var centipedeModels: [CentipedeModel] = []
    var timer: Timer?
    
    init(width: CGFloat, height: CGFloat, scene: SKScene) {
        self.width = width
        self.height = height
        
        spaceX = (width / CGFloat(xCount))
        spaceY = (height / CGFloat(yCount))
        
        self.scene = scene
        addCentipede(x: 16, y: yCount, direction: 1, bodyCount: 16)
//        addCentipede(x: 0, y: yCount, bodyCount: 1)
        DispatchQueue.main.async { [weak self] in
            self?.start()
        }
    }

    func stop() {
        timer?.invalidate()
    }
    
    var speed = 1.0 {
        didSet {
            timer?.invalidate()
            start()
        }
    }
    
    private func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 1/speed, repeats: true) { [weak self] _ in
            guard let strongSelf = self else { return }
            for centipedeModel in strongSelf.centipedeModels {
                var lastX: Int = 0
                var lastY: Int = 0

                centipedeModel.centipede.takeTurn()

                for sprite in centipedeModel.sprites {
                    if sprite == centipedeModel.sprites.first {
                        lastX = sprite.gridX
                        lastY = sprite.gridY

                        let x = CGFloat(centipedeModel.centipede.xPosition) * strongSelf.spaceX + strongSelf.spaceX/2
                        let y = CGFloat(centipedeModel.centipede.yPosition) * strongSelf.spaceY - strongSelf.spaceY/2
//                        print("Moving head to \(x), \(y)")
                        sprite.run(SKAction.move(to: CGPoint(x: x, y: y), duration: 1/strongSelf.speed))
                        sprite.gridX = centipedeModel.centipede.xPosition
                        sprite.gridY = centipedeModel.centipede.yPosition
                    } else {
                        let currentX = sprite.gridX
                        let currentY = sprite.gridY
//                        print("Moving body part to \(lastX), \(lastY)")
                        let x = CGFloat(lastX) * strongSelf.spaceX + strongSelf.spaceX/2
                        let y = CGFloat(lastY) * strongSelf.spaceY - strongSelf.spaceY/2
                        sprite.run(SKAction.move(to: CGPoint(x: x, y: y), duration: 1/strongSelf.speed))
                        sprite.gridX = lastX
                        sprite.gridY = lastY
                        lastX = currentX
                        lastY = currentY
                    }
                }
            }
        }
        timer?.fire()
    }
    
    @discardableResult
    func addCentipede(x: Int, y: Int, direction: Int, bodyCount: Int) -> Centipede
    {
        let centipede = Centipede(bodyCount: bodyCount, gridWidth: xCount, gridHeight: yCount, startX: x, startY: y, grid: self)
        centipede.direction = direction
        let spritesList = sprites(for: centipede, x: x, y: y, direction: direction)
        centipedeModels.append(CentipedeModel(centipede: centipede, sprites: spritesList))
        
        return centipede
    }
    
    func remove(centipede: Centipede) {
        if let index = centipedeModels.index(where: { $0.centipede.xPosition == centipede.xPosition && $0.centipede.yPosition == centipede.yPosition }) {
            centipedeModels.remove(at: index)
        }
    }
    
    func sprites(for centipede: Centipede, x: Int, y: Int, direction: Int) -> [CentipedeSprite] {
        print("Creating \(centipede.bodyCount) sprites starting at \(x), \(y)")
        var sprites: [CentipedeSprite] = []
        for i in 0..<centipede.bodyCount {
            // Create sprite
            let head = CentipedeSprite(imageNamed: "head")
            
            let originalWidth = head.size.width
            let width = spaceX
            let scale = width / originalWidth
            let height = head.size.height * scale
            head.size = CGSize(width: width, height: height)
            head.gridX = x - (i * direction)
            head.gridY = y
            
            let physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(width / 2.0))
            physicsBody.isDynamic = true
            physicsBody.categoryBitMask = PhysicsCategory.centipedePart
            physicsBody.contactTestBitMask = PhysicsCategory.bullet & PhysicsCategory.ship
            physicsBody.collisionBitMask = PhysicsCategory.none
            head.physicsBody = physicsBody
            
            head.position = CGPoint(x: CGFloat(head.gridX) * spaceX + spaceX/2, y: CGFloat(y) * spaceY - spaceY/2)

            scene?.addChild(head)
            sprites.append(head)
        }
        
        return sprites
    }
    
    func rebuildCentipedes()
    {
        for var model in centipedeModels {
            model.sprites.forEach { $0.removeFromParent() }
            model.sprites = sprites(for: model.centipede, x: model.centipede.xPosition, y: model.centipede.yPosition, direction: model.centipede.direction)
        }
    }

    func centipedeWasHit(_ centipedeSprite: SKSpriteNode) {
        guard let centipedeSprite = centipedeSprite as? CentipedeSprite else { return }
        for var model in centipedeModels {
            if let index = model.sprites.index(of: centipedeSprite) {
                model.centipede.hit(at: index, x: centipedeSprite.gridX, y: centipedeSprite.gridY)
                
                // remove sprites that are gone
                for i in index..<model.sprites.count {
                    model.sprites[i].removeFromParent()
                }
                model.sprites.removeLast(model.sprites.count - model.centipede.bodyCount)
            }
        }
//        rebuildCentipedes()
    }
    
//    var action: SKAction {
//        return SKAction.repeatForever(SKAction.sequence([
//            SKAction.wait(forDuration: 0.2),
//
//            ]))
//    }
}
