//
//  GameScene.swift
//  TappyDragonML
//
//  Created by Ian Hanken on 3/25/16.
//  Copyright (c) 2016 Ian Hanken. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    
    var backgroundLayer = SKNode()
    var midgroundLayer = SKNode()
    var foregroundLayer = SKNode()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0.0, y: 0.0)
        
        setUpBackground()
        setUpMidground()
        setUpForeground()
    }
    
    func setUpBackground() {
        let background = SKSpriteNode(imageNamed: "background")
        
        background.anchorPoint = CGPoint(x: 0.0, y: 0)
        
        background.position = CGPoint(x: 0.0, y: 0.0)
        
        backgroundLayer.zPosition = 0
        
        addChild(backgroundLayer)
        
        backgroundLayer.addChild(background)
    }
    
    func setUpMidground() {
//        let midgroundSky = SKSpriteNode(imageNamed: "layer3")
//        let midgroundGround = SKSpriteNode(imageNamed: "layer2dark")
//        
//        midgroundSky.anchorPoint = CGPoint(x: 0, y: 0)
//        midgroundGround.anchorPoint = CGPoint(x: 0, y: 0)
//        
//        midgroundSky.anchorPoint = CGPoint(x: 0, y: 0.0)
//        midgroundGround.position = CGPoint(x: 0, y: 375)
        
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
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            
            self.addChild(sprite)
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
