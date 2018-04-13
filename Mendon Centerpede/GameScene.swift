//
//  GameScene.swift
//  Mendon Centerpede
//
//  Created by Scott J. Kleper on 4/10/18.
//  Copyright © 2018 Boat Launch, Inc. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    private let ship = SKSpriteNode(imageNamed: "ship")
    private let head = SKSpriteNode(imageNamed: "head")
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.purple
        ship.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        let originalWidth = ship.size.width
        let width = size.width / 20.0
        let scale = width / originalWidth
        let height = ship.size.height * scale
        ship.size = CGSize(width: width, height: height)
        addChild(ship)
        
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addHead),
                SKAction.wait(forDuration: 1.0)
                ])
        ))
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func addHead() {
        
        // Create sprite
        let head = SKSpriteNode(imageNamed: "head")
        
        let originalWidth = head.size.width
        let width = size.width / 20.0
        let scale = width / originalWidth
        let height = head.size.height * scale
        head.size = CGSize(width: width, height: height)
        
        // Determine where to spawn the monster along the Y axis
        let actualY = random(min: head.size.height/2, max: size.height - head.size.height/2)
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        head.position = CGPoint(x: size.width + head.size.width/2, y: actualY)
        
        // Add the monster to the scene
        addChild(head)
        
        // Determine speed of the monster
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        
        // Create the actions
        let actionMove = SKAction.move(to: CGPoint(x: -head.size.width/2, y: actualY), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        head.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let projectile = SKSpriteNode(imageNamed: "pixel")
        projectile.position = ship.position
        projectile.size = CGSize(width: ship.size.width * 0.1, height: ship.size.height * 0.1)

        addChild(projectile)
        
        let moveAction = SKAction.move(to: CGPoint(x: projectile.position.x, y: size.height), duration: 2.0)
        let moveActionDone = SKAction.removeFromParent()
        projectile.run(SKAction.sequence([moveAction, moveActionDone]))
    }
    /*
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    override func didMove(to view: SKView) {
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }*/
}
