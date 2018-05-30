//
//  GameScene.swift
//  Mendon Centerpede
//
//  Created by Scott J. Kleper on 4/10/18.
//  Copyright © 2018 Boat Launch, Inc. All rights reserved.
//

import SpriteKit
import QuartzCore
import GameplayKit

func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
}

func random(min: CGFloat, max: CGFloat) -> CGFloat {
    return random() * (max - min) + min
}

func random(min: Int, max: Int) -> Int {
    return min + Int(arc4random_uniform(UInt32(max - min)))
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
    private var joystick: Joystick!
    
    var gameIsOver = false
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.purple
        
        grid = Grid(width: size.width, height: size.height, scene: self)

        addShip()
        addRandomMushrooms()
        addJoystick()
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero
    }

    var spriteSize: CGSize {
        let originalWidth = ship.size.width
        let width = size.width / 20.0
        let scale = width / originalWidth
        let height = ship.size.height * scale
        return CGSize(width: width, height: height)
    }
    
    private let numMushrooms = 12
    func addRandomMushrooms() {
        guard let grid = grid else { return }
        for _ in 0..<numMushrooms {
            var added = false
            while !added {
                added = grid.addMushroom(x: random(min: 0, max: grid.xCount),
                                         y: random(min: 5, max: grid.yCount - 2))
            }
        }
    }
    
    func addShip() {
        ship.size = spriteSize
        ship.position = CGPoint(x: size.width * 0.5, y: ship.size.height * 2)
        
        let physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: spriteSize.width, height: spriteSize.height))
        physicsBody.isDynamic = true
        physicsBody.categoryBitMask = PhysicsCategory.ship
        physicsBody.contactTestBitMask = PhysicsCategory.centipedePart
        physicsBody.collisionBitMask = PhysicsCategory.none
        physicsBody.usesPreciseCollisionDetection = true
        ship.physicsBody = physicsBody
        
        addChild(ship)
    }
    
    func addJoystick() {
        let thumb = SKSpriteNode(imageNamed: "joystick")
        let backdrop = SKSpriteNode(imageNamed: "dpad")
        joystick = Joystick(thumb: thumb, andBackdrop: backdrop)
        joystick.position = CGPoint(x: backdrop.size.width, y: backdrop.size.height)
        
        addChild(joystick)
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

    let shipMovementRows:CGFloat = 5
    let velocityMultiplier:CGFloat = 7
    override func update(_ currentTime: TimeInterval) {
        var vector = CGVector(dx: joystick.velocity.x * velocityMultiplier,
                              dy: joystick.velocity.y * velocityMultiplier)
        
        if ship.position.y < ship.size.height && vector.dy < 0 {
            vector.dy = 0
        }
        if ship.position.x < ship.size.width && vector.dx < 0 {
            vector.dx = 0
        }
        if ship.position.x + ship.size.width > self.size.width && vector.dx > 0 {
            vector.dx = 0
        }
        if ship.position.y > ship.size.height * shipMovementRows && vector.dy > 0 {
            vector.dy = 0
        }
        
        ship.physicsBody?.velocity = vector
    }
    
    func bulletDidHitMushroom(bullet: SKSpriteNode, mushroom: MushroomSprite) {
        print("Hit mushroom")
        bullet.removeFromParent()
        mushroom.hit()
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
