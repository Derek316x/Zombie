//
//  GameScene.swift
//  ZombieConga
//
//  Created by Z on 8/21/15.
//  Copyright (c) 2015 dereknetto. All rights reserved.
//

import SpriteKit

//Everything that appears on the screen in SpriteKit derives from the SKNode class
class GameScene: SKScene {
    
    let zombie1 = SKSpriteNode(imageNamed: "zombie1");
    
    var playableRect: CGRect
    
    //time
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0

    let zombieMovePointsPerSec: CGFloat = 240
    var velocity = CGPointZero
    
    override init(size: CGSize) {
        let maxAspectRatio = 16.0/9.0 as CGFloat
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height - playableHeight)/2.0
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
        super.init(size: size)
    }
    
    //Whenever you override the default initializer of a Sprite Kit node, you must also override the required NSCoder initializer. This is used when you are loading a scene from the scene editor.
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        
        //background stuff
        backgroundColor = SKColor.whiteColor()
        let background = SKSpriteNode(imageNamed: "background1")
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5) // default
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = -1
        addChild(background)
        
        //zombie stuff
        zombie1.position = CGPoint(x: 400, y: 400)
        addChild(zombie1)
        print("zombie zPos: \(zombie1.zPosition)")
        print("ZOMBIE Xscale: \(zombie1.xScale)")
        print("ZOMBIE Yscale: \(zombie1.yScale)")
        
        debugDrawPlayableArea()
    }
    
    override func update(currentTime: NSTimeInterval) {

        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else{
            dt = 0
        }
        lastUpdateTime = currentTime
        
        moveSprite(zombie1, velocity: velocity)
        boundsCheckZombie()
        rotateSprite(zombie1, direction: velocity)
    }
    
    //MARK: Zombie movement methods
    func moveZombieToward(location:CGPoint){ //updates zombie velocity
        let offset = CGPoint(x: location.x - zombie1.position.x, y: location.y - zombie1.position.y)
        let length = sqrt(Double(offset.x * offset.x + offset.y * offset.y))
        
        //unit vector
        let direction = CGPoint(x: offset.x / CGFloat(length), y: offset.y / CGFloat(length))
        print("\(direction)")
        
        //velocity vector
        velocity = CGPoint(x: direction.x * zombieMovePointsPerSec, y: direction.y * zombieMovePointsPerSec)
        print("\(velocity)")
    }

    func boundsCheckZombie(){
        let bottomLeft = CGPoint(x: 0, y: CGRectGetMinY(playableRect))
        let topRight = CGPoint(x: size.width, y:CGRectGetMaxY(playableRect))
        
        //left bounds check
        if zombie1.position.x < bottomLeft.x{
            zombie1.position.x = bottomLeft.x
            velocity.x = -velocity.x
        }
        //right bounds check
        if zombie1.position.x > topRight.x{
            zombie1.position.x = topRight.x
            velocity.x = -velocity.x
        }
        //top bounds check
        if zombie1.position.y > topRight.y{
            zombie1.position.y = topRight.y
            velocity.y = -velocity.y
        }
        //bottom bounds check
        if zombie1.position.y < bottomLeft.y{
            zombie1.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
    }
    
    //MARK: Sprite methods
    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint){
        let amountToMove = CGPoint(x: velocity.x * CGFloat(dt),y: velocity.y * CGFloat(dt))
        sprite.position = CGPoint(x: sprite.position.x + amountToMove.x, y: sprite.position.y + amountToMove.y)
    }
    
    func rotateSprite(sprite:SKSpriteNode, direction:CGPoint){
        sprite.zRotation = CGFloat(atan2(Double(direction.y), Double(direction.x)))
        let degrees = zombie1.zRotation * CGFloat((180/M_PI))
        print("rotation: \(degrees)")
    }

    //MARK: Touch handling methods
    func sceneTouched(touchLocation:CGPoint){
        moveZombieToward(touchLocation)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first! as UITouch //only consider the first touch
        let touchLocation = touch.locationInNode(self)
        sceneTouched(touchLocation)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first! as UITouch //only consider the first touch
        let touchLocation = touch.locationInNode(self)
        sceneTouched(touchLocation)
    }
    
    //MARK: Debug methods
    func debugDrawPlayableArea() {
        let shape = SKShapeNode()
        let path = CGPathCreateMutable()
        CGPathAddRect(path, nil, playableRect)
        shape.path = path
        shape.strokeColor = SKColor.redColor()
        shape.lineWidth = 4.0
        addChild(shape)
    }
}
