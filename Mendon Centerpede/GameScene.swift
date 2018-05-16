//
//  GameScene.swift
//  Mendon Centerpede
//
//  Created by Scott J. Kleper on 4/10/18.
//  Copyright © 2018 Boat Launch, Inc. All rights reserved.
//

import SpriteKit
import GameplayKit

func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
}

func random(min: CGFloat, max: CGFloat) -> CGFloat {
    return random() * (max - min) + min
}

struct PhysicsCategory {
    static let none: UInt32 = 0
    static let all: UInt32 = UInt32.max
    static let centipedePart: UInt32 = 0b1
    static let mushroom: UInt32 = 0b10
    static let bullet: UInt32 = 0b100
    static let ship: UInt32 = 0b1000
}

class GameScene: SKScene {
    private let ship = SKSpriteNode(imageNamed: "ship")
    private let head = SKSpriteNode(imageNamed: "head")
    private var grid: Grid?
    var gameIsOver = false
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.purple
        addShip()
        addRandomMushrooms()
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero
        
        let repeatAction = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addHead),
                SKAction.wait(forDuration: 1.0)
                ])
        )
        
//        let shootingAction = SKAction.repeatForever(
//            SKAction.sequence([
//                SKAction.run(shoot),
//                SKAction.wait(forDuration: 0.2)
//                ])
//        )
        
        grid = Grid(width: size.width, height: size.height, scene: self)
        
        run(repeatAction, withKey: "centipede-spawner")
//        run(shootingAction, withKey: "shooting")
    }

    private var spriteSize: CGSize {
        let originalWidth = ship.size.width
        let width = size.width / 20.0
        let scale = width / originalWidth
        let height = ship.size.height * scale
        return CGSize(width: width, height: height)
    }
    
    private let numMushrooms = 1
    func addRandomMushrooms() {
        for _ in 0..<numMushrooms {
            let mushroom = MushroomSprite()
            mushroom.size = spriteSize
            mushroom.position = CGPoint(x: size.width * 0.5, y: 20)

            addChild(mushroom)
        }
    }
    
    func addShip() {
        ship.position = CGPoint(x: size.width * 0.5, y: 0)
        ship.size = spriteSize
        
        let physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: spriteSize.width, height: spriteSize.height))
        physicsBody.isDynamic = true
        physicsBody.categoryBitMask = PhysicsCategory.ship
        physicsBody.contactTestBitMask = PhysicsCategory.centipedePart
        physicsBody.collisionBitMask = PhysicsCategory.none
        physicsBody.usesPreciseCollisionDetection = true
        ship.physicsBody = physicsBody
        
        addChild(ship)
    }
    
    func shoot() {
        let projectile = SKSpriteNode(imageNamed: "pixel")
        projectile.position = ship.position
        projectile.size = CGSize(width: ship.size.width * 0.1, height: ship.size.height * 0.1)
        
        let physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        physicsBody.isDynamic = true
        physicsBody.categoryBitMask = PhysicsCategory.bullet
        physicsBody.contactTestBitMask = PhysicsCategory.centipedePart
        physicsBody.collisionBitMask = PhysicsCategory.none
        physicsBody.usesPreciseCollisionDetection = true
        projectile.physicsBody = physicsBody
        
        addChild(projectile)
        
        let moveAction = SKAction.move(to: CGPoint(x: projectile.position.x, y: size.height), duration: 2.0)
        let moveActionDone = SKAction.removeFromParent()
        projectile.run(SKAction.sequence([moveAction, moveActionDone]))
    }
    
    func addHead() {
        
//        // Create sprite
//        let head = SKSpriteNode(imageNamed: "head")
//
//        let originalWidth = head.size.width
//        let width = size.width / 20.0
//        let scale = width / originalWidth
//        let height = head.size.height * scale
//        head.size = CGSize(width: width, height: height)
//
//        let physicsBody = SKPhysicsBody(circleOfRadius: width / 2.0)
//        physicsBody.isDynamic = true
//        physicsBody.categoryBitMask = PhysicsCategory.centipedePart
//        physicsBody.contactTestBitMask = PhysicsCategory.bullet & PhysicsCategory.ship
//        physicsBody.collisionBitMask = PhysicsCategory.none
//        head.physicsBody = physicsBody
//
//        // Determine where to spawn the monster along the Y axis
//        let actualY = random(min: head.size.height/2, max: size.height - head.size.height/2)
//
//        // Position the monster slightly off-screen along the right edge,
//        // and along a random position along the Y axis as calculated above
//        head.position = CGPoint(x: size.width + head.size.width/2, y: actualY)
//
//        // Add the monster to the scene
//        addChild(head)
//
//        // Determine speed of the monster
//        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
//
//        // Create the actions
//        let actionMove = SKAction.move(to: CGPoint(x: -head.size.width/2, y: actualY), duration: TimeInterval(actualDuration))
//        let actionMoveDone = SKAction.removeFromParent()
//        head.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    var lastTouch: CGPoint? = nil
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        lastTouch = touchLocation
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        lastTouch = touchLocation
    }
    
    // Be sure to clear lastTouch when touches end so that the impulses stop being applies
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouch = nil
        let shootAction = SKAction.run(shoot)
        run(shootAction)
    }

    override func update(_ currentTime: TimeInterval) {
        if let touch = lastTouch {
            let adjustedTouch = CGPoint(x: touch.x, y: min(touch.y, size.height / 4.0))
            let vector = CGVector(dx: (adjustedTouch.x - ship.position.x), dy: (adjustedTouch.y - ship.position.y))
//            ship.physicsBody?.applyImpulse(impulseVector)
            ship.physicsBody?.velocity = vector
        }
    }
//    override func update(currentTime: CFTimeInterval) {
//        // Only add an impulse if there's a lastTouch stored
//        if let touch = lastTouch {
//            let impulseVector = CGVector(touch.x - myShip.position.x, 0)
//            // If myShip starts moving too fast or too slow, you can multiply impulseVector by a constant or clamp its range
//            myShip.physicsBody.applyImpluse(impulseVector)
//        }
//    }
    /*
    let velocity: Float = 1000.0
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        // todo: limit max y
        
        // cancel any existing moves
        removeAction(forKey: "moving")
        
        // move the ship towards this location
        let distanceX = abs(location.x - ship.position.x)
        let distanceY = abs(location.y - ship.position.y)
        let mostPointsToMove = max(distanceX, distanceY)
        let duration = Float(mostPointsToMove) / velocity
        let moveAction = SKAction.move(to: location, duration: Double(duration))
        ship.run(moveAction, withKey: "moving")
    }
    */
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//    }
    
    func bulletDidHitMushroom(bullet: SKSpriteNode, mushroom: MushroomSprite) {
        print("Hit mushroom")
    }
    
    func bulletDidHitCentipedePart(bullet: SKSpriteNode, centipedePart: SKSpriteNode) {
        print("Hit")
        bullet.removeFromParent()
        centipedePart.removeFromParent()
        grid?.centipedeWasHit(centipedePart)
    }
    
    func gameOver() {
        gameIsOver = true
        self.removeAllChildren()
        self.removeAction(forKey: "centipede-spawner")
        self.removeAction(forKey: "shooting")
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.centipedePart != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.bullet != 0)) {
            if let centipedePart = firstBody.node as? SKSpriteNode,
                let bullet = secondBody.node as? SKSpriteNode {
                bulletDidHitCentipedePart(bullet: bullet, centipedePart: centipedePart)
            }
        } else if ((firstBody.categoryBitMask & PhysicsCategory.mushroom != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.bullet != 0)) {
            if let mushroom = firstBody.node as? MushroomSprite,
                let bullet = secondBody.node as? SKSpriteNode {
                bulletDidHitMushroom(bullet: bullet, mushroom: mushroom)
            }
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.centipedePart != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.ship != 0)) {
            gameOver()
        }
    }
}
