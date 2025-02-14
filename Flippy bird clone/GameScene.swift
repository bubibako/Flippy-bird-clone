//
//  GameScene.swift
//  Flippy bird clone
//
//  Created by Arthur Trampnau on 30/01/25.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    var pipeSpeed: TimeInterval = 4.0 
    var bird: SKSpriteNode!
    var score = 0
    let scoreLabel = SKLabelNode(fontNamed: "Arial")

    struct PhysicsCategory {
        static let bird: UInt32 = 1
        static let pipe: UInt32 = 2
        static let ground: UInt32 = 4
        static let scoreZone: UInt32 = 8
    }

    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        self.size = view.bounds.size
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -5)

        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint.zero
        background.zPosition = -1
        background.size = CGSize(width: self.size.width, height: self.size.height)
        addChild(background)

        let ground = SKNode()
        ground.position = CGPoint(x: size.width / 2, y: 0)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: 10))
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = PhysicsCategory.ground
        addChild(ground)

        bird = SKSpriteNode(imageNamed: "bird")
        bird.position = CGPoint(x: -self.size.width / 3, y: 0)
        bird.zPosition = 1

        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2)
        bird.physicsBody?.isDynamic = true
        bird.physicsBody?.affectedByGravity = true
        bird.physicsBody?.allowsRotation = false
        bird.physicsBody?.categoryBitMask = PhysicsCategory.bird
        bird.physicsBody?.contactTestBitMask = PhysicsCategory.pipe | PhysicsCategory.ground | PhysicsCategory.scoreZone
        bird.physicsBody?.collisionBitMask = PhysicsCategory.ground
        addChild(bird)

        scoreLabel.text = "0"
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 50)
        scoreLabel.fontSize = 40
        scoreLabel.fontColor = .white
        addChild(scoreLabel)

        let pipeSpawnTimer = SKAction.repeatForever(SKAction.sequence([
            SKAction.run(spawnPipes),
            SKAction.wait(forDuration: 2.0)
        ]))
        run(pipeSpawnTimer)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 40))
    }

    func spawnPipes() {
        let pipeUp = SKSpriteNode(imageNamed: "pipeUp")
        let pipeDown = SKSpriteNode(imageNamed: "pipeDown")
        
        let pipeGap: CGFloat = bird.size.height * 4
        let minY = size.height * 0.2
        let maxY = size.height * 0.7
        let randomY = CGFloat.random(in: minY...maxY)
        pipeUp.size.height = size.height
        pipeDown.size.height = size.height
        
        pipeUp.position = CGPoint(x: size.width / 2 + pipeUp.size.width, y: randomY)
        pipeDown.position = CGPoint(x: size.width / 2 + pipeDown.size.width, y: randomY - pipeGap - pipeDown.size.height)

        pipeUp.physicsBody = SKPhysicsBody(rectangleOf: pipeUp.size)
        pipeUp.physicsBody?.isDynamic = false
        pipeUp.physicsBody?.categoryBitMask = PhysicsCategory.pipe
        
        pipeDown.physicsBody = SKPhysicsBody(rectangleOf: pipeDown.size)
        pipeDown.physicsBody?.isDynamic = false
        pipeDown.physicsBody?.categoryBitMask = PhysicsCategory.pipe
        
        addChild(pipeUp)
        addChild(pipeDown)
        
        let moveAction = SKAction.moveBy(x: -size.width - pipeUp.size.width, y: 0, duration: pipeSpeed)
        let removeAction = SKAction.removeFromParent()
        let pipeSequence = SKAction.sequence([moveAction, removeAction])

        pipeUp.run(pipeSequence)
        pipeDown.run(pipeSequence)
        
        let speedIncreaseTimer = SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: 10),
            SKAction.run {
                if self.pipeSpeed > 2.0 {
                    self.pipeSpeed -= 0.2
                }
            }
        ]))

        run(speedIncreaseTimer)

        let scoreNode = SKNode()
        scoreNode.position = CGPoint(x: pipeUp.position.x + pipeUp.size.width / 2, y: size.height / 2)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1, height: size.height))
        scoreNode.physicsBody?.isDynamic = false
        scoreNode.physicsBody?.categoryBitMask = PhysicsCategory.pipe
        scoreNode.physicsBody?.contactTestBitMask = PhysicsCategory.bird
        
        addChild(scoreNode)
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA.categoryBitMask
        let secondBody = contact.bodyB.categoryBitMask

        if (firstBody == PhysicsCategory.bird && secondBody == PhysicsCategory.pipe) ||
           (firstBody == PhysicsCategory.pipe && secondBody == PhysicsCategory.bird) ||
           (firstBody == PhysicsCategory.bird && secondBody == PhysicsCategory.ground) ||
           (firstBody == PhysicsCategory.ground && secondBody == PhysicsCategory.bird) {
            gameOver()
        }

        if (firstBody == PhysicsCategory.bird && secondBody == PhysicsCategory.scoreZone) ||
           (firstBody == PhysicsCategory.scoreZone && secondBody == PhysicsCategory.bird) {
            increaseScore()
        }
    }

    func gameOver() {
        isUserInteractionEnabled = false
        bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        bird.removeAllActions()
        
        enumerateChildNodes(withName: "//*") { node, _ in
            node.removeAllActions()
        }

        let menuScene = MenuScene(size: self.size)
        menuScene.scaleMode = .aspectFill
        self.view?.presentScene(menuScene, transition: SKTransition.fade(withDuration: 1.0))
    }


    func increaseScore() {
        score += 1
        scoreLabel.text = "\(score)"
    }
    
    
}
