//
//  MenuScene.swift
//  Flippy bird clone
//
//  Created by Arthur Trampnau on 14/02/25.
//

import SpriteKit

class MenuScene: SKScene {
    
    override func didMove(to view: SKView) {
        self.backgroundColor = .cyan

        let titleLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        titleLabel.text = "Flappy Bird"
        titleLabel.fontSize = 50
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.7)
        addChild(titleLabel)
 
        let startButton = SKLabelNode(fontNamed: "Arial-BoldMT")
        startButton.text = "Начать игру"
        startButton.name = "startButton" 
        startButton.fontSize = 40
        startButton.fontColor = .black
        startButton.position = CGPoint(x: size.width / 2, y: size.height * 0.5)
        addChild(startButton)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let tappedNodes = nodes(at: location)
            
            for node in tappedNodes {
                if node.name == "startButton" {
                    let gameScene = GameScene(size: self.size)
                    gameScene.scaleMode = .aspectFill
                    self.view?.presentScene(gameScene, transition: SKTransition.fade(withDuration: 1.0))
                }
            }
        }
    }
}
