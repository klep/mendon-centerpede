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

    weak var scene: GameScene?
    var centipedeModels: [CentipedeModel] = []
    var mushrooms: Set<MushroomSprite> = []
    var timer: Timer?
    
    init(width: CGFloat, height: CGFloat, scene: GameScene) {
        self.width = width
        self.height = height
        
        spaceX = (width / CGFloat(xCount))
        spaceY = (height / CGFloat(yCount))
        
        self.scene = scene
        addCentipede(x: 0, y: yCount, direction: 1, bodyCount: 16)
//        addCentipede(x: 0, y: yCount, bodyCount: 1)
        DispatchQueue.main.async { [weak self] in
            self?.start()
        }
    }

    func stop() {
        timer?.invalidate()
    }
    
    var speed = 3.0 {
        didSet {
            speed = min(speed, 9)
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
                        sprite.run(SKAction.move(to: CGPoint(x: x, y: y), duration: 1/strongSelf.speed))
                        sprite.gridX = centipedeModel.centipede.xPosition
                        sprite.gridY = centipedeModel.centipede.yPosition
                        sprite.color = centipedeModel.centipede.color
                    } else {
                        let currentX = sprite.gridX
                        let currentY = sprite.gridY
                        sprite.color = centipedeModel.centipede.color
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
    
    @discardableResult
    func addMushroom(x: Int, y: Int) -> Bool
    {
        if hasMushroom(x: x, y: y) { return false }
        
        let mushroom = MushroomSprite()
        mushroom.gridX = x
        mushroom.gridY = y
        position(mushroom, x: x, y: y)
        // adjust the size a bit to avoid overlap
        mushroom.size = CGSize(width: mushroom.size.width, height: mushroom.size.height * 0.9)

        let physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: mushroom.size.width, height: mushroom.size.height))
        physicsBody.isDynamic = true
        physicsBody.categoryBitMask = PhysicsCategory.mushroom
        physicsBody.contactTestBitMask = PhysicsCategory.bullet | PhysicsCategory.centipedePart
        physicsBody.collisionBitMask = PhysicsCategory.none
        mushroom.physicsBody = physicsBody
        
        mushrooms.insert(mushroom)
        scene?.addChild(mushroom)
        return true
    }
    
    private func position(_ sprite: GridSprite, x: Int, y: Int) {
        guard let scene = scene else { return }
        
        sprite.size = scene.spriteSize
        sprite.gridX = x
        sprite.gridY = y
        sprite.position = CGPoint(x: CGFloat(sprite.gridX) * spaceX + spaceX/2,
                                  y: CGFloat(y) * spaceY - spaceY/2)
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
            let segment = CentipedeSprite()
            segment.isHead = (i == 0)
            
            position(segment, x: x - (i * direction), y: y)
            
            let physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(spaceX / 2.0))
            physicsBody.isDynamic = true
            physicsBody.categoryBitMask = PhysicsCategory.centipedePart
            physicsBody.contactTestBitMask = PhysicsCategory.bullet | PhysicsCategory.ship | PhysicsCategory.mushroom
            physicsBody.collisionBitMask = PhysicsCategory.none
            segment.physicsBody = physicsBody

            scene?.addChild(segment)
            sprites.append(segment)
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
    
    func hasMushroom(x: Int, y: Int) -> Bool {
        // todo: come on. make this instant lookup
        return mushrooms.reduce(false, { $0 || $1.gridX == x && $1.gridY == y })
    }
    
    func hasCentipede(x: Int, y: Int) -> Bool {
        // todo: should be instant
        for model in centipedeModels {
            if model.sprites.reduce(false, { $0 || $1.gridX == x && $1.gridY == y }) {
                return true
            }
        }
        return false
    }
//    var action: SKAction {
//        return SKAction.repeatForever(SKAction.sequence([
//            SKAction.wait(forDuration: 0.2),
//
//            ]))
//    }
}
