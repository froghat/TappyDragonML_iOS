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
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    
    var backgroundLayer = SKNode()
    var midgroundLayer = SKNode()
    var foregroundLayer = SKNode()
    var poles = SKNode()
    var menu = SKNode()
    var scoreLabel = SKLabelNode()
    
    var dragon: SKSpriteNode?
    
    var score: Int?
    
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
        
        setUpBackground()
        setUpMidground()
        setUpForeground()
        setUpDragon()
        
        loadMenu()
    }
    
    func loadMenu() {
        let title = SKSpriteNode(imageNamed: "title")
        title.position = CGPointMake(self.size.width / 2, (self.size.height * 3) / 4)
        title.zPosition = 3
        menu.addChild(title)
        
        let playButton = SKSpriteNode(imageNamed: "playbutton")
        playButton.name = "playButton"
        playButton.position = CGPointMake((7 * self.size.width) / 24, (2 * self.size.height) / 6)
        playButton.zPosition = 3
        menu.addChild(playButton)
        
        let rateButton = SKSpriteNode(imageNamed: "ratebutton2")
        rateButton.name = "rateButton"
        rateButton.position = CGPointMake((17 * self.size.width) / 24, (2 * self.size.height) / 6)
        rateButton.zPosition = 3
        menu.addChild(rateButton)
        
        let twitterButton = SKSpriteNode(imageNamed: "twitterbutton")
        twitterButton.name = "twitterButton"
        twitterButton.position = CGPointMake(0.5 * self.size.width, 0.22 * self.size.height)
        twitterButton.zPosition = 3
        menu.addChild(twitterButton)
        
        let froghatLabel = SKSpriteNode(imageNamed: "froghatsoftware")
        froghatLabel.position = CGPointMake(0.5 * self.size.width, 0.11 * self.size.height)
        froghatLabel.zPosition = 3
        menu.addChild(froghatLabel)
        
        addChild(menu)
    }
    
    func beginGame() {
        // Get rid of the menu
        menu.removeAllChildren()
        
        // Spawn pipes repeatedly.
        addChild(poles)
        let spawn = SKAction.performSelector(#selector(setUpPoles), onTarget: self)
        let delay = SKAction.waitForDuration(2)
        let spawnThenDelay = SKAction.sequence([spawn, delay])
        let spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)
        self.runAction(spawnThenDelayForever)
        
        // Set up physics the world's physics, including gravity.
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsBody?.categoryBitMask = worldCategory
        self.physicsBody?.collisionBitMask = dragonCategory
        self.physicsBody?.contactTestBitMask = dragonCategory
        self.physicsWorld.gravity = CGVectorMake(0.0, -8.0)
        self.physicsWorld.contactDelegate = self
        
        // Set up the physics of the dragon.
        dragon!.physicsBody = SKPhysicsBody(texture: dragon!.texture!, size: dragon!.texture!.size())
        dragon!.physicsBody!.dynamic = true
        dragon!.physicsBody!.allowsRotation = false
        dragon!.physicsBody?.categoryBitMask = dragonCategory
        dragon!.physicsBody?.collisionBitMask = worldCategory | poleCategory
        dragon!.physicsBody?.contactTestBitMask = worldCategory | poleCategory
        
        score = 0
        scoreLabel = SKLabelNode(fontNamed: "MarkerFelt-Wide")
        scoreLabel.setScale(5)
        scoreLabel.position = CGPointMake(self.size.width / 2, (4 * self.size.height) / 5)
        scoreLabel.zPosition = 4
        scoreLabel.text = "\(score!)"
        addChild(scoreLabel)
    }
    
    func setUpDragon() {
        dragon = SKSpriteNode(imageNamed: "dragon0")
        
        // Set the sprite's position.
        //dragon!.anchorPoint = self.convertPointToView(CGPoint(x: dragon!.size.width / 2, y: dragon!.size.height / 2))
        dragon!.position = CGPointMake((self.size.width / 2), (self.size.height / 2))
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
        let action = SKAction.animateWithTextures(textures, timePerFrame: 0.05)
        dragon!.runAction(SKAction.repeatActionForever(action))
        
        // Add the dragon to the scene.
        addChild(dragon!)
    }
    
    func setUpPoles() {
        let pole = SKSpriteNode(imageNamed: "pole2")
        pole.name = "pole"
        let gear = SKSpriteNode(imageNamed: "gear")
        gear.name = "gear"
        let contactNode = SKNode()
        
        // Create a node for a single pole pair. Multiple pole pairs may be on the screen at once.
        let polePair = SKNode()
        
        // Set the poles at a position off screen and in front of the background nodes.
        polePair.position = CGPointMake(self.size.width + gear.size.width, 0)
        polePair.zPosition = 4
        
        // Chose a random height for the pole gap within a certain range.
        let y = CGFloat(arc4random()) % (self.size.height / 4)
        
        // Set up the poles and gears.
        polePair.addChild(setUpPoleNode(CGPointMake(0, y), node: SKSpriteNode(imageNamed: "pole1")))
        polePair.addChild(setUpPoleNode(CGPointMake(0, y + pole.size.height - poleGap - 45), node: SKSpriteNode(imageNamed: "gear")))
        polePair.addChild(setUpPoleNode(CGPointMake(0, y + pole.size.height + poleGap), node: SKSpriteNode(imageNamed: "pole2")))
        polePair.addChild(setUpPoleNode(CGPointMake(0, y + pole.size.height + 30), node: SKSpriteNode(imageNamed: "gear")))
        
        // Set up the score contact node.
        contactNode.position = CGPointMake(pole.size.width + dragon!.size.width / 2, CGRectGetMidY(self.frame))
        contactNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(pole.size.width, self.frame.size.height))
        contactNode.physicsBody?.dynamic = false
        contactNode.physicsBody?.categoryBitMask = scoreCategory
        contactNode.physicsBody?.collisionBitMask = dragonCategory
        contactNode.physicsBody?.contactTestBitMask = dragonCategory
        contactNode.name = "contactNode"
        polePair.addChild(contactNode)
        
        // Set the poles in motion, and remove them when the leave the left side of the screeen.
        let movePoles = SKAction.moveByX(-(self.size.width + gear.size.width * 2), y: 0, duration: 4)
        let removePoles = SKAction.removeFromParent()
        polePair.runAction(SKAction.sequence([movePoles, removePoles]))
        
        poles.addChild(polePair)
    }
    
    func setUpPoleNode(point: CGPoint, node: SKSpriteNode) -> SKSpriteNode {
        node.position = point
        node.physicsBody = SKPhysicsBody(texture: node.texture!, size: node.texture!.size())
        node.physicsBody?.dynamic = false
        if node.name == "gear" {
            node.zPosition = 3
        }
        else {
            node.zPosition = 4
        }
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
        prepareAnimation("layer2dark", layer: midgroundLayer, y: 375, duration: 25)
        prepareAnimation("layer3", layer: midgroundLayer, y: 0, duration: 15)
    }
    
    func setUpForeground() {
        addChild(foregroundLayer)
        foregroundLayer.zPosition = 2
        
        // Animate the foreground layer.
        prepareAnimation("layer1dark", layer: foregroundLayer, y: 0, duration: 5)
    }
    
    func prepareAnimation(imageName: String, layer: SKNode, y: CGFloat, duration: NSTimeInterval) {
        for i in 0..<2 {
            let node = SKSpriteNode(imageNamed: imageName)
            node.anchorPoint = CGPoint(x: 0, y: 0)
            node.position = CGPoint(x: (node.size.width * CGFloat(i)) + 0, y: y)
            node.runAction(animateLeft(node, y: 0, duration: duration))
            layer.addChild(node)
        }
    }
    
    func animateLeft(node: SKSpriteNode, y: CGFloat, duration: NSTimeInterval) -> SKAction {
        let moveLeft = SKAction.moveByX(-node.size.width, y: y, duration: duration)
        let moveReset = SKAction.moveByX(node.size.width, y: y, duration: 0)
        let moveLoop = SKAction.sequence([moveLeft, moveReset])
        
        return SKAction.repeatActionForever(moveLoop)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        let touch = touches.first! as UITouch
        let positionInScene = touch.locationInNode(self)
        let touchedNode = self.nodeAtPoint(positionInScene)
        
        if let name = touchedNode.name {
            if name == "playButton" {
                beginGame()
            }
            else if name == "rateButton" {
                //UIApplication.sharedApplication().openURL(NSURL(string : "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=\(APP_ID)&onlyLatestVersion=true&pageNumber=0&sortOrdering=1)")!)
                print("Rate Button Pressed")
            }
            else if name == "twitterButton" {
                print("Twitter Button Pressed")
            }
        }
        
        dragon?.physicsBody?.velocity = CGVectorMake(0, 0)
        dragon?.physicsBody?.applyImpulse(CGVectorMake(0, 250))
    }
   
    func didBeginContact(contact: SKPhysicsContact) {
        
        if ((contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory) {
            if contact.bodyA.node?.name == "contactNode" {
                contact.bodyA.categoryBitMask = 1 << 5
            }
            else {
                contact.bodyB.categoryBitMask = 1 << 5
            }
            score! += 1
            scoreLabel.text = "\(score!)"
        }
        else if contact.bodyA.categoryBitMask == (1 << 5) || contact.bodyB.categoryBitMask == (1 << 5) {
            
        }
        else {
            restart()
            // Stop the dragon.
            dragon?.physicsBody?.velocity = CGVectorMake(0, 0)
        }
    }
    
    func restart() {
        resetScene()
        score! = 0
        scoreLabel.text = "\(score!)"
    }
    
    func resetScene() {
        // Center the dragon again.
        dragon!.runAction(SKAction.moveTo(CGPointMake(self.size.width / 2, self.size.height / 2), duration: 0))
        
        // Remove all poles.
        poles.removeAllChildren()
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
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if dragon?.physicsBody != nil {
            dragon!.zRotation = clamp(-0.5, max: 0.5, value: dragon!.physicsBody!.velocity.dy * (dragon!.physicsBody!.velocity.dy < 0 ? 0.001 : 0.0005))
        }
    }
}
