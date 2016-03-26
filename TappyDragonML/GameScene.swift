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
        
        let background = SKSpriteNode(imageNamed: "background")
        let midgroundSky = SKSpriteNode(imageNamed: "layer3")
        let midgroundGround = SKSpriteNode(imageNamed: "layer2dark")
        let foreground = SKSpriteNode(imageNamed: "layer1dark")
        
        midgroundSky.setScale(0.25)
        midgroundGround.setScale(0.4)
        foreground.setScale(0.2)
        
        background.anchorPoint = CGPoint(x: 0, y: 0)
        midgroundSky.anchorPoint = CGPoint(x: 0, y: 0)
        midgroundGround.anchorPoint = CGPoint(x: 0, y: 0)
        foreground.anchorPoint = CGPoint(x: 0, y: 0)
        
        background.position = CGPoint(x: 0.0, y: -(background.frame.height - screenHeight))
        midgroundSky.anchorPoint = CGPoint(x: 0, y: -(midgroundSky.frame.height - screenHeight))
        midgroundGround.position = CGPoint(x: 0, y: 0)
        foreground.position = CGPoint(x: 0, y: 0)
        
        addChild(backgroundLayer)
        addChild(midgroundLayer)
        addChild(foregroundLayer)
        
        backgroundLayer.addChild(background)
        midgroundLayer.addChild(midgroundSky)
        midgroundLayer.addChild(midgroundGround)
        foregroundLayer.addChild(foreground)
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
