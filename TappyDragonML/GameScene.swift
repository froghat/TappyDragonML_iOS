//
//  GameScene.swift
//  TappyDragonML
//
//  Created by Ian Hanken on 3/25/16.
//  Copyright (c) 2016 Ian Hanken. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    let poleGap: CGFloat = 600
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    
    var backgroundLayer = SKNode()
    var midgroundLayer = SKNode()
    var foregroundLayer = SKNode()
    
    var dragon: SKSpriteNode?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        setUpBackground()
        setUpMidground()
        setUpForeground()
        
        setUpDragon()
        
        print("Before Selector")
        let spawn = SKAction.performSelector(#selector(setUpPoles), onTarget: self)
        print("Past Selector")
        let delay = SKAction.waitForDuration(2)
        let spawnThenDelay = SKAction.sequence([spawn, delay])
        let spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)
        self.runAction(spawnThenDelayForever)
    }
    
    func setUpDragon() {
        dragon = SKSpriteNode(imageNamed: "dragon0")
        
        dragon!.anchorPoint = self.convertPointToView(CGPoint(x: dragon!.size.width / 2, y: dragon!.size.height / 2))
        dragon!.position = CGPoint(x: (self.size.width / 2), y: (self.size.height / 2))
        dragon!.zPosition = 3
        
        dragon!.physicsBody = SKPhysicsBody(circleOfRadius: dragon!.size.height / 2)
        dragon!.physicsBody!.dynamic = true
        dragon!.physicsBody!.allowsRotation = false
        
        var textures = [SKTexture]()
        let atlas = SKTextureAtlas(named: "dragon.atlas")
        
        for i in 0...7 {
            textures.append(atlas.textureNamed("dragon\(i)"))
        }
        for i in 0...6 {
            textures.append(atlas.textureNamed("dragon\(6 - i)"))
        }
        
        let action = SKAction.animateWithTextures(textures, timePerFrame: 0.05)
        dragon!.runAction(SKAction.repeatActionForever(action))
        
        addChild(dragon!)
    }
    
    func setUpPoles() {
        let bottomPole = SKSpriteNode(imageNamed: "pole1")
        let topPole = SKSpriteNode(imageNamed: "pole2")
        let bottomGear = SKSpriteNode(imageNamed: "gear")
        let topGear = SKSpriteNode(imageNamed: "gear")
        
        let polePair = SKNode()
        
        polePair.position = CGPointMake(self.size.width + bottomPole.size.width * 2, 0)
        polePair.zPosition = 3
        
        let y = CGFloat(arc4random()) % (self.size.height / 3)
        
        bottomPole.position = CGPointMake(0, y)
        bottomPole.physicsBody = SKPhysicsBody(rectangleOfSize: bottomPole.size)
        bottomPole.physicsBody?.dynamic = false
        bottomGear.position = CGPointMake(0, y + bottomPole.size.height - poleGap - 25)
        bottomGear.physicsBody = SKPhysicsBody(circleOfRadius: bottomGear.size.height / 2 - 10)
        bottomGear.physicsBody?.dynamic = false
        bottomGear.zPosition = 4
        polePair.addChild(bottomPole)
        polePair.addChild(bottomGear)
        
        topPole.position = CGPointMake(0, y + topPole.size.height + poleGap)
        topPole.physicsBody = SKPhysicsBody(rectangleOfSize: topPole.size)
        topPole.physicsBody?.dynamic = false
        topGear.position = CGPointMake(0, y + topPole.size.height + 7)
        topGear.physicsBody = SKPhysicsBody(circleOfRadius: topGear.size.height / 2 - 10)
        topGear.physicsBody?.dynamic = false
        topGear.zPosition = 4
        polePair.addChild(topPole)
        polePair.addChild(topGear)
        
        let movePoles = SKAction.moveByX(-self.size.width * 1.5, y: 0, duration: 4)
        let removePoles = SKAction.removeFromParent()
        polePair.runAction(SKAction.sequence([movePoles, removePoles]))
        
        foregroundLayer.addChild(polePair)
    }
    
    func setUpBackground() {
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
        
        prepareAnimation("layer2dark", layer: midgroundLayer, y: 375, duration: 25)
        prepareAnimation("layer3", layer: midgroundLayer, y: 0, duration: 15)
    }
    
    func setUpForeground() {
        addChild(foregroundLayer)
        foregroundLayer.zPosition = 2
        
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
        dragon!.physicsBody!.velocity = CGVectorMake(0, 0)
        dragon!.physicsBody!.applyImpulse(CGVectorMake(0, 400))
    }
   
    
    func clamp(min: CGFloat, max: CGFloat, value: CGFloat) -> CGFloat {
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
        dragon?.zRotation = clamp(-1, max: 0.5, value: dragon!.physicsBody!.velocity.dy * (dragon!.physicsBody!.velocity.dy < 0 ? 0.001 : 0.0005))
    }
}
