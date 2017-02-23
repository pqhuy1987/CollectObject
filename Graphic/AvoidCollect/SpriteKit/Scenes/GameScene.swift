//
//  GameScene.swift
//  AvoidCollect
//
//  Created by Eric Internicola on 2/20/16.
//  Copyright (c) 2016 Eric Internicola. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    var player: SKSpriteNode?
    var squareCollect: SKSpriteNode?
    var circleAvoid: SKShapeNode?
    var stars: SKSpriteNode?
    var lblScore: SKLabelNode?
    var lblMain: SKLabelNode?
    var level: Level = Level.createLevel(4)
    var circleCount = 0
    var squareCount = 0

    let hudColor = UIColor.blue
    let backColor = UIColor(red: 20/255, green: 100/255, blue: 100/255, alpha: 1)
    let circleColor = UIColor(red: 60/255, green: 60/255, blue: 50/255, alpha: 1)
    let squareColor = UIColor(red: 200/255, green: 200/255, blue: 100/255, alpha: 1)
    let starColor = UIColor(red: 170/255, green: 200/255, blue: 160/255, alpha: 1)
    let playerColor = UIColor.red
    
    var isAlive = true
    var isLevelComplete = false
    var score = 0
}

// MARK: - Scene Methods
extension GameScene {
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        backgroundColor = backColor
        
        spawnPlayer()
        spawnSquareCollect()
        spawnCircleAvoid()
        spawnStars()
        spawnScoreLabel()
        spawnMainLabel()
        
        squareSpawnTimer()
        circleSpawnTimer()
        starsSpawnTimer()
    }
   
    override func update(_ currentTime: TimeInterval) {
        if let player = player, let lblScore = lblScore, !isAlive {
            player.position.x = -200
            lblScore.position.x = frame.midX
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if let player = player, let lblScore = lblScore, isAlive {
                player.position.x = location.x
                lblScore.position.x = location.x
            } else {
                player?.position.x = -200
            }
        }
    }
}


// MARK: - Spawn Methods
extension GameScene {
    func spawnPlayer() {
        player = SKSpriteNode(color: playerColor, size: CGSize(width: 50, height: 50))
        if let player = player {
            player.position = CGPoint(x: frame.midX, y: frame.minY+player.size.height*2)
            player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
            player.physicsBody?.affectedByGravity = false
            player.physicsBody?.categoryBitMask = PhysicsCategory.player
            player.physicsBody?.contactTestBitMask = PhysicsCategory.squareCollect | PhysicsCategory.circleAvoid
            player.physicsBody?.isDynamic = false
            
            addChild(player)
        }
    }
    
    func spawnSquareCollect() {
        squareCollect = SKSpriteNode(color: squareColor, size: CGSize(width: 30, height: 30))
        if let squareCollect = squareCollect {
            squareCollect.position = CGPoint(x: Double(arc4random_uniform(UInt32(frame.maxX))), y: Double(frame.maxY + squareCollect.size.height * 2))
            squareCollect.physicsBody = SKPhysicsBody(rectangleOf: squareCollect.size)
            squareCollect.physicsBody?.affectedByGravity = false
            squareCollect.physicsBody?.categoryBitMask = PhysicsCategory.squareCollect
            squareCollect.physicsBody?.contactTestBitMask = PhysicsCategory.player
            squareCollect.physicsBody?.isDynamic = true
            squareCollect.physicsBody?.allowsRotation = false
            
            addChild(squareCollect)
            squareCount += 1

            let moveForward = SKAction.moveTo(y: -100, duration: level.squareSpeed)
            let destroy = SKAction.removeFromParent()
            squareCollect.run(SKAction.sequence([moveForward, destroy]))
        }
    }
    
    func spawnCircleAvoid() {
        if circleCount < level.circlesToDodge {
            let radius: CGFloat = 15
            circleAvoid = SKShapeNode(circleOfRadius: radius)
            if let circleAvoid = circleAvoid {
                circleAvoid.strokeColor = UIColor.clear
                circleAvoid.fillColor = circleColor
                let xPosition = CGFloat(arc4random_uniform(UInt32(frame.maxX)))

                circleAvoid.position = CGPoint(x: xPosition, y: frame.maxY + radius)
                
                circleAvoid.physicsBody = SKPhysicsBody(circleOfRadius: radius)
                circleAvoid.physicsBody?.affectedByGravity = false
                circleAvoid.physicsBody?.categoryBitMask = PhysicsCategory.circleAvoid
                circleAvoid.physicsBody?.contactTestBitMask = PhysicsCategory.player
                circleAvoid.physicsBody?.collisionBitMask = PhysicsCategory.player
                circleAvoid.physicsBody?.isDynamic = true
                circleAvoid.physicsBody?.allowsRotation = false
                
                addChild(circleAvoid)
                circleCount += 1
                // TODO: Rip out debugging output
                print("Spawned circle \(circleCount) of \(level.circlesToDodge)")

                let moveForward = SKAction.moveTo(y: -100, duration: level.circleSpeed)
                let destroy = SKAction.removeFromParent()
                circleAvoid.run(SKAction.sequence([moveForward, destroy]))
            }
        } else if !isLevelComplete && isAlive {
            isLevelComplete = true
            let wait = SKAction.wait(forDuration: level.circleSpeed)
            let levelCompleteCheck = SKAction.run {
                if self.isAlive {
                    self.levelComplete()
                }
            }
            run(SKAction.sequence([wait, levelCompleteCheck]))
        }
    }
    
    func spawnStars() {
        let randomSize = CGFloat(arc4random_uniform(3))
        let randomSpeed = TimeInterval(arc4random_uniform(2) + 1)
        stars = SKSpriteNode(color: starColor, size: CGSize(width: randomSize, height: randomSize))
        if let stars = stars {
            stars.position = CGPoint(x: Double(arc4random_uniform(UInt32(frame.maxX))), y: Double(frame.maxY + randomSize*2))
            stars.zPosition = -1
            
            let moveForward = SKAction.moveTo(y: -100, duration: randomSpeed)
            let destroy = SKAction.removeFromParent()
            stars.run(SKAction.sequence([moveForward, destroy]))
            
            addChild(stars)
        }
    }
    
    func spawnScoreLabel() {
        lblScore = SKLabelNode(fontNamed: "Courier")
        if let lblScore = lblScore, let player = player {
            lblScore.fontSize = 60
            lblScore.fontColor = hudColor
            lblScore.position = CGPoint(x: player.position.x, y: player.position.y - 80)
            lblScore.text = "\(score)"
            
            addChild(lblScore)
        }
    }
    
    func spawnMainLabel() {
        lblMain = SKLabelNode(fontNamed: "Courier")
        if let lblMain = lblMain {
            lblMain.fontSize = 80
            lblMain.fontColor = hudColor
            lblMain.position = CGPoint(x: frame.midX, y: frame.midY)
            lblMain.text = "Start!"
            
            lblMain.run(SKAction.sequence([SKAction.wait(forDuration: 3.0), SKAction.run {
                lblMain.alpha = 0
            }]))
            
            addChild(lblMain)
        }
    }
    
    func spawnExplosion(_ circleAvoid: SKShapeNode) {
        if let explosionEmitterPath = Bundle.main.path(forResource: "particleExplosion", ofType: "sks"), let explosion = NSKeyedUnarchiver.unarchiveObject(withFile: explosionEmitterPath) as? SKEmitterNode {
            explosion.position = CGPoint(x: circleAvoid.position.x, y: circleAvoid.position.y)
            explosion.zPosition = 1
            explosion.targetNode = self
            
            run(SKAction.sequence([SKAction.wait(forDuration: 1), SKAction.removeFromParent()]))
            addChild(explosion)
        } else {
            print("ERROR: Couldn't find explosion")
        }
    }
}

// MARK: - Timer Methods
extension GameScene {
    func squareSpawnTimer() {
        let squareTimer = SKAction.wait(forDuration: level.squareTimer)
        let spawn = SKAction.run {
            self.spawnSquareCollect()
        }
        let sequence = SKAction.sequence([squareTimer, spawn])
        run(SKAction.repeatForever(sequence))
    }
    
    func circleSpawnTimer() {
        let circleTimer = SKAction.wait(forDuration: level.circleTimer)
        let spawn = SKAction.run {
            self.spawnCircleAvoid()
        }
        let sequence = SKAction.sequence([circleTimer, spawn])
        run(SKAction.repeatForever(sequence))
    }
    
    func starsSpawnTimer() {
        let starsTimer = SKAction.wait(forDuration: 0.05)
        let spawn = SKAction.run {
            self.spawnStars()
        }
        let sequence = SKAction.sequence([starsTimer, spawn])
        run(SKAction.repeatForever(sequence))
    }
}

// MARK: - SKPhysicsContactDelegate Methods
extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB

        // Player / Square Collect collision
        if (firstBody.categoryBitMask == PhysicsCategory.player && secondBody.categoryBitMask == PhysicsCategory.squareCollect) || (firstBody.categoryBitMask == PhysicsCategory.squareCollect && secondBody.categoryBitMask == PhysicsCategory.player) {
            playerSquareCollision(firstBody.node as? SKSpriteNode , squareTemp: secondBody.node as? SKSpriteNode)
        } else if (firstBody.categoryBitMask == PhysicsCategory.player && secondBody.categoryBitMask == PhysicsCategory.circleAvoid) || (firstBody.categoryBitMask == PhysicsCategory.circleAvoid && secondBody.categoryBitMask == PhysicsCategory.player) {

            if let circleAvoid = firstBody.node as? SKShapeNode, let player = secondBody.node as? SKSpriteNode {
                spawnExplosion(circleAvoid)
                playerCircleCollision(player, circleTemp: circleAvoid)
            } else if let player = firstBody.node as? SKSpriteNode, let circleAvoid = secondBody.node as? SKShapeNode {
                spawnExplosion(circleAvoid)
                playerCircleCollision(player, circleTemp: circleAvoid)
            }
        }
    }

    // MARK: Contact Handler Methods

    func playerSquareCollision(_ playerTemp: SKSpriteNode?, squareTemp: SKSpriteNode?) {
        if let _ = playerTemp, let squareTemp = squareTemp {
            squareTemp.removeFromParent()
            score += 1
            updateScore()
        }
    }

    func playerCircleCollision(_ playerTemp: SKSpriteNode, circleTemp: SKShapeNode) {
        if let lblMain = lblMain {
            lblMain.alpha = 1
            lblMain.text = "Game Over"
            isAlive = false
            waitThenMoveToTitleScene()
        }
    }
}

// MARK: - Helper Methods
extension GameScene {
    func updateScore() {
        if let lblScore = lblScore {
            lblScore.text = "\(score)"
        }
    }
    
    func waitThenMoveToTitleScene() {
        let wait = SKAction.wait(forDuration: 2)
        let transition = SKAction.run {
            if let view = self.view, let scene = TitleScene(fileNamed: "TitleScene") {
                view.ignoresSiblingOrder = true
                scene.scaleMode = .aspectFill
                view.presentScene(scene)
            }
        }
        let sequence = SKAction.sequence([wait, transition])
        run(SKAction.repeat(sequence, count: 1))
    }

    func levelComplete() {
        print("Level Complete")
        if let lblMain = lblMain {
            lblMain.alpha = 1
            lblMain.text = "Level \(level.number) Complete"

            level = Level.createLevel(level.number + 1)

            let wait = SKAction.wait(forDuration: 2)
            let levelIntroAction = SKAction.run {
                lblMain.text = "Level \(self.level.number)"
            }
            let wait2 = SKAction.wait(forDuration: 1)
            let levelStartAction = SKAction.run {
                lblMain.text = "Start!"
            }
            let wait3 = SKAction.wait(forDuration: 1)
            let beginNextLevelAction = SKAction.run {
                lblMain.alpha = 0
                self.beginNextLevel()
            }

            run(SKAction.sequence([wait, levelIntroAction, wait2, levelStartAction, wait3, beginNextLevelAction]))
        }
    }

    func beginNextLevel() {
        isLevelComplete = false
        isAlive = true
        circleCount = 0
        squareCount = 0
    }
}

// MARK: - Structures
extension GameScene {
    struct PhysicsCategory {
        static let player: UInt32 = 1
        static let squareCollect: UInt32 = 2 << 0
        static let circleAvoid: UInt32 = 2 << 1
    }
}
