//
//  GameScene.swift
//  TappyDragonML
//
//  Created by Ian Hanken on 3/25/16.
//  Copyright (c) 2016 Ian Hanken. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let poleGap: CGFloat = 600
    
    let screenWidth = UIScreen.main().bounds.width
    let screenHeight = UIScreen.main().bounds.height
    
    var backgroundLayer = SKNode()
    var midgroundLayer = SKNode()
    var foregroundLayer = SKNode()
    var poles = SKNode()
    var menu = SKNode()
    var getReady = SKNode()
    var scoreLabel: SKLabelNode?
    var tweetScoreButton: SKSpriteNode?
    
    var dragon: SKSpriteNode?
    
    var score: Int?
    
    var machineLearningOn: Bool?
    
    // SKPhysicsContact constants
    let dragonCategory: UInt32 = 1 << 0
    let worldCategory: UInt32 = 1 << 1
    let poleCategory: UInt32 = 1 << 2
    let scoreCategory: UInt32 = 1 << 3
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        // Set up the main elements of the scene.
        setUpBackground()
        setUpMidground()
        setUpForeground()
        setUpDragon()
        
        // Present the menu to the user.
        loadMenu()
    }
    
    func loadMenu() {
        // Tappy Dragon Title
        let title = SKSpriteNode(imageNamed: "title")
        title.position = CGPoint(x: self.size.width / 2, y: (self.size.height * 3) / 4)
        title.zPosition = 3
        menu.addChild(title)
        
        // Play Button
        let playButton = SKSpriteNode(imageNamed: "playbutton")
        playButton.name = "playButton"
        playButton.position = CGPoint(x: (7 * self.size.width) / 24, y: (2 * self.size.height) / 6)
        playButton.zPosition = 3
        menu.addChild(playButton)
        
        // Rate Button
        let rateButton = SKSpriteNode(imageNamed: "ratebutton2")
        rateButton.name = "rateButton"
        rateButton.position = CGPoint(x: (17 * self.size.width) / 24, y: (2 * self.size.height) / 6)
        rateButton.zPosition = 3
        menu.addChild(rateButton)
        
        // Twitter Button
        let twitterButton = SKSpriteNode(imageNamed: "twitterbutton")
        twitterButton.name = "twitterButton"
        twitterButton.position = CGPoint(x: 0.5 * self.size.width, y: 0.22 * self.size.height)
        twitterButton.zPosition = 3
        menu.addChild(twitterButton)
        
        // Froghat Software Label
        let froghatLabel = SKSpriteNode(imageNamed: "froghatsoftware")
        froghatLabel.position = CGPoint(x: 0.5 * self.size.width, y: 0.11 * self.size.height)
        froghatLabel.zPosition = 3
        menu.addChild(froghatLabel)
        
        addChild(menu)
    }
    
    func getPlayerReady() {
        // Get rid of the menu.
        menu.removeFromParent()
        
        // Set up the get ready screen and present it.
        getReady.zPosition = 4
        
        let getReadyLabel = SKSpriteNode(imageNamed: "get_ready")
        getReadyLabel.position = CGPoint(x: self.size.width / 2, y: (3 * self.size.height) / 4)
        getReady.addChild(getReadyLabel)
        
        let tap = SKSpriteNode(imageNamed: "tap")
        tap.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        getReady.addChild(tap)
        
        addChild(getReady)
    }
    
    func beginGame() {
        // Get rid of the menu
        menu.removeFromParent()
        
        // Spawn pipes repeatedly.
        addChild(poles)
        let spawn = SKAction.perform(#selector(setUpPoles), onTarget: self)
        let delay = SKAction.wait(forDuration: 2)
        let spawnThenDelay = SKAction.sequence([spawn, delay])
        let spawnThenDelayForever = SKAction.repeatForever(spawnThenDelay)
        self.run(spawnThenDelayForever)
        
        // Set up physics the world's physics, including gravity.
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.categoryBitMask = worldCategory
        self.physicsBody?.collisionBitMask = dragonCategory
        self.physicsBody?.contactTestBitMask = dragonCategory
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -8.0)
        self.physicsWorld.contactDelegate = self
        
        // Set up the physics of the dragon.
        dragon!.physicsBody = SKPhysicsBody(texture: dragon!.texture!, size: dragon!.texture!.size())
        dragon!.physicsBody!.isDynamic = true
        dragon!.physicsBody!.allowsRotation = false
        dragon!.physicsBody?.categoryBitMask = dragonCategory
        dragon!.physicsBody?.collisionBitMask = worldCategory | poleCategory
        dragon!.physicsBody?.contactTestBitMask = worldCategory | poleCategory
        
        // Set the score to zero on game start.
        score = 0
        scoreLabel = SKLabelNode(fontNamed: "Superclarendon-BlackItalic")
        scoreLabel?.setScale(5)
        scoreLabel?.position = CGPoint(x: self.size.width / 2, y: (4 * self.size.height) / 5)
        scoreLabel?.zPosition = 100
        scoreLabel?.text = "\(score!)"
        addChild(scoreLabel!)
    }
    
    func setUpDragon() {
        dragon = SKSpriteNode(imageNamed: "dragon0")
        
        // Set the sprite's position.
        //dragon!.anchorPoint = self.convertPointToView(CGPoint(x: dragon!.size.width / 2, y: dragon!.size.height / 2))
        dragon!.position = CGPoint(x: (self.size.width / 2), y: (self.size.height / 2))
        dragon!.zPosition = 3
        
        // Animate the dragon.
        var textures = [SKTexture]()
        let atlas = SKTextureAtlas(named: "dragon.atlas")
        
        // Load frames for flapping from up to down.
        for i in 0...7 {
            textures.append(atlas.textureNamed("dragon\(i)"))
        }
        
        // Load frames for flapping back up.
        for i in 1...6 {
            textures.append(atlas.textureNamed("dragon\(6 - i)"))
        }
        
        // Repeat the frame sequence endlessly.
        let action = SKAction.animate(with: textures, timePerFrame: 0.05)
        dragon!.run(SKAction.repeatForever(action))
        
        // Add the dragon to the scene.
        addChild(dragon!)
    }
    
    func setUpPoles() {
        let pole = SKSpriteNode(imageNamed: "pole2")
        let gear = SKSpriteNode(imageNamed: "gear")
        let contactNode = SKNode()
        
        // Create a node for a single pole pair. Multiple pole pairs may be on the screen at once.
        let polePair = SKNode()
        polePair.removeAllChildren()
        
        // Set the poles at a position off screen and in front of the background nodes.
        polePair.position = CGPoint(x: self.size.width + gear.size.width, y: 0)
        polePair.zPosition = 4
        
        // Chose a random height for the pole gap within a certain range.
        let y = CGFloat(arc4random()).truncatingRemainder(dividingBy: (self.size.height / 4))
        
        // Set up the poles and gears.
        polePair.addChild(setUpPoleNode(point: CGPoint(x: 0, y: y), node: SKSpriteNode(imageNamed: "pole1"), asset: "pole"))
        polePair.addChild(setUpPoleNode(point: CGPoint(x: 0, y: y + pole.size.height - poleGap - 45), node: SKSpriteNode(imageNamed: "gear"), asset: "gear"))
        polePair.addChild(setUpPoleNode(point: CGPoint(x: 0, y: y + pole.size.height + poleGap), node: SKSpriteNode(imageNamed: "pole2"), asset: "pole"))
        polePair.addChild(setUpPoleNode(point: CGPoint(x: 0, y: y + pole.size.height + 30), node: SKSpriteNode(imageNamed: "gear"), asset: "gear"))
        
        // Set up the score contact node.
        contactNode.position = CGPoint(x: pole.size.width + dragon!.size.width / 2, y: self.frame.midY)
        contactNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pole.size.width, height: self.frame.size.height))
        contactNode.physicsBody?.isDynamic = false
        
        // The contact node should only consider contact with the dragon a collision.
        contactNode.physicsBody?.categoryBitMask = scoreCategory
        contactNode.physicsBody?.collisionBitMask = dragonCategory
        contactNode.physicsBody?.contactTestBitMask = dragonCategory
        contactNode.name = "contactNode"
        polePair.addChild(contactNode)
        
        // Set the poles in motion, and remove them when the leave the left side of the screeen.
        let movePoles = SKAction.moveBy(x: -(self.size.width + gear.size.width * 2), y: 0, duration: 4)
        let removePoles = SKAction.removeFromParent()
        polePair.run(SKAction.sequence([movePoles, removePoles]))
        
        poles.addChild(polePair)
    }
    
    func setUpPoleNode(point: CGPoint, node: SKSpriteNode, asset: String) -> SKSpriteNode {
        node.position = point
        node.physicsBody = SKPhysicsBody(texture: node.texture!, size: node.texture!.size())
        node.physicsBody?.isDynamic = false
        
        // Set the zPosition of the node based on whether it is a gear or a pole.
        if asset == "gear" {
            node.zPosition = 3
        }
        else {
            node.zPosition = 4
        }
        
        // Make sure the node only considers contact with the dragon a collision.
        node.physicsBody?.categoryBitMask = poleCategory
        node.physicsBody?.collisionBitMask = dragonCategory
        node.physicsBody?.contactTestBitMask = dragonCategory
        
        return node
    }
    
    func setUpBackground() {
        // The background should be static
        let background = SKSpriteNode(imageNamed: "background")
        background.anchorPoint = CGPoint(x: 0.0, y: 0)
        background.position = CGPoint(x: 0.0, y: -background.size.height + self.size.height)
        backgroundLayer.zPosition = 0
        
        addChild(backgroundLayer)
        
        backgroundLayer.addChild(background)
    }
    
    func setUpMidground() {
        addChild(midgroundLayer)
        midgroundLayer.zPosition = 1
        
        // Animate the midground layer.
        prepareAnimation(imageName: "layer2dark", layer: midgroundLayer, y: 375, duration: 25)
        prepareAnimation(imageName: "layer3", layer: midgroundLayer, y: 0, duration: 15)
    }
    
    func setUpForeground() {
        addChild(foregroundLayer)
        foregroundLayer.zPosition = 2
        
        // Animate the foreground layer.
        prepareAnimation(imageName: "layer1dark", layer: foregroundLayer, y: 0, duration: 5)
    }
    
    func prepareAnimation(imageName: String, layer: SKNode, y: CGFloat, duration: TimeInterval) {
        for i in 0..<2 {
            let node = SKSpriteNode(imageNamed: imageName)
            node.anchorPoint = CGPoint(x: 0, y: 0)
            node.position = CGPoint(x: (node.size.width * CGFloat(i)) + 0, y: y)
            node.run(animateLeft(node: node, y: 0, duration: duration))
            layer.addChild(node)
        }
    }
    
    func animateLeft(node: SKSpriteNode, y: CGFloat, duration: TimeInterval) -> SKAction {
        let moveLeft = SKAction.moveBy(x: -node.size.width, y: y, duration: duration)
        let moveReset = SKAction.moveBy(x: node.size.width, y: y, duration: 0)
        let moveLoop = SKAction.sequence([moveLeft, moveReset])
        
        return SKAction.repeatForever(moveLoop)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Start the game when a user taps on the get ready screen.
        if getReady.parent == self {
            getReady.removeFromParent()
            print("Beginning game")
            beginGame()
        }
        
        let touch = touches.first! as UITouch
        let positionInScene = touch.location(in: self)
        let touchedNode = self.atPoint(positionInScene)
        
        // Restart the game if a game over has occurred and the user touches OUTSIDE of the tweet score button.
        if tweetScoreButton?.parent == self {
            if touchedNode.name == nil {
                restart()
            }
        }
        
        if let name = touchedNode.name {
            if name == "playButton" {
                // Run the game with machine learning off.
                getPlayerReady()
                machineLearningOn = false
            }
            else if name == "rateButton" {
                //UIApplication.sharedApplication().openURL(NSURL(string : "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=\(APP_ID)&onlyLatestVersion=true&pageNumber=0&sortOrdering=1)")!)
                print("Rate Button Pressed")
            }
            else if name == "twitterButton" {
                // Run the game with machine learning on.
                print("Twitter Button Pressed")
                machineLearningOn = true
                beginGame()
            }
            else if name == "tweetScore" {
                print("Tweet Score Button Pressed")
            }
        }
        
        // Apply an impulse to the dragon and reset the velocity on each tap.
        dragon?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        dragon?.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 250))
    }
   
    func didBegin(_ contact: SKPhysicsContact) {
        // Check to see if either node is a contact node for score detection.
        if ((contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory) {
            // Set the categoryBitMask of whichever node is the contactNode to an unused bit shift.
            if contact.bodyA.node?.name == "contactNode" {
                contact.bodyA.categoryBitMask = 1 << 5
            }
            else {
                contact.bodyB.categoryBitMask = 1 << 5
            }
            // Increment the score.
            score! += 1
            scoreLabel?.text = "\(score!)"
        }
        else if contact.bodyA.categoryBitMask == (1 << 5) || contact.bodyB.categoryBitMask == (1 << 5) {
            // Do nothing.
        }
        else {
            if machineLearningOn! == false {
                // Since machine learning is not running, present a game over.
                presentGameOver()
                // Stop the dragon.
                dragon!.removeFromParent()
                poles.removeFromParent()
            }
            else {
                // Since machine learning is running, just reset the game state.
                dragon?.removeFromParent() // Delete the current dragon.
                setUpDragon() // Spawn a new dragon
                self.removeAllActions() // Stop spawning poles.
                poles.removeAllChildren() // Delete all remaining poles.
                poles.removeFromParent() // Remove the poles node.
                scoreLabel?.removeFromParent() // Remove the score so a duplicate score is not shown.
                beginGame() // Begin again
            }
        }
    }
    
    func restart() {
        // Remove all children and actions so the next play doesn't spawn extra pipes.
        self.removeAllChildren()
        self.removeAllActions()
        
        // Make sure no extra pipes are left over.
        poles.removeAllChildren()
        
        // Set the game back up.
        setUpBackground()
        setUpMidground()
        setUpForeground()
        setUpDragon()
        
        loadMenu()
        
        // Reset the score.
        score! = 0
        scoreLabel?.text = "\(score!)"
    }
    
    func presentGameOver() {
        // Present a game over message.
        let gameOverMessage = SKSpriteNode(imageNamed: "gameover")
        gameOverMessage.position = CGPoint(x: self.size.width / 2, y: (5 * self.size.height) / 8)
        gameOverMessage.zPosition = 8
        
        addChild(gameOverMessage)
        
        // Show the tweet score button and add it to the scene.
        tweetScoreButton = SKSpriteNode(imageNamed: "tweetscorebutton")
        tweetScoreButton?.position = CGPoint(x: self.size.width / 2, y: (3 * self.size.height) / 8)
        tweetScoreButton?.zPosition = 8
        tweetScoreButton?.name = "tweetScore"
        
        addChild(tweetScoreButton!)
        
        
    }
    
    func clamp(min: CGFloat, max: CGFloat, value: CGFloat) -> CGFloat {
        // Use this to only allow a specific range of dragon tilt.
        if value > max {
            return max
        }
        else if value < min {
            return min
        }
        else {
            return value
        }
    }
    
    override func update(_ currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if dragon?.physicsBody != nil {
            dragon!.zRotation = clamp(min: -0.5, max: 0.5, value: dragon!.physicsBody!.velocity.dy * (dragon!.physicsBody!.velocity.dy < 0 ? 0.001 : 0.0005))
        }
    }
}
