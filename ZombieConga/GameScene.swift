//
//  GameScene.swift
//  ZombieConga
//
//  Created by Z on 8/21/15.
//  Copyright (c) 2015 dereknetto. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    let zombie1 = SKSpriteNode(imageNamed: "zombie1");
    let zombieAnimation : SKAction
    
    var playableRect: CGRect
    var lastTouchLocation = CGPointZero
    
    //time
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0

    let zombieMovePointsPerSec: CGFloat = 240
    let zombieRotateRadiansPerSec: CGFloat = 4.0 * pi
    var velocity = CGPointZero
    
    //preload sounds
    let catCollisionSound: SKAction = SKAction.playSoundFileNamed("hitCat.wav", waitForCompletion: false)
    let enemyCollisionSound: SKAction = SKAction.playSoundFileNamed("hitCatLady.wav", waitForCompletion: false)
    
    override init(size: CGSize) {
        let maxAspectRatio = 16.0/9.0 as CGFloat
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height - playableHeight)/2.0
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
        
        var textures:[SKTexture] = []
        for i in 1...4{
            let texture = SKTexture(imageNamed: "zombie\(i)")
            textures.append(texture)
        }
        textures.append(textures[2])
        textures.append(textures[1])
        
        zombieAnimation = SKAction.repeatActionForever(SKAction.animateWithTextures(textures, timePerFrame: 0.1))
        
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
        
        //spawn enemy every 2 seconds
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(spawnEnemy),SKAction.waitForDuration(2.0)])))
        
        //spawn cats!
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(spawnCat),SKAction.waitForDuration(1.0)])))
        
        debugDrawPlayableArea()
    }
    
    override func update(currentTime: NSTimeInterval) {

        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else{
            dt = 0
        }
        lastUpdateTime = currentTime
        
        //code for zombie to stop at touch
        let distanceRemaining = (zombie1.position - lastTouchLocation).length()
        let distanceToMoveThisFrame = zombieMovePointsPerSec * CGFloat(dt)
        
        if distanceRemaining >= distanceToMoveThisFrame{
            moveSprite(zombie1, velocity: velocity)
            rotateSprite(zombie1, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec)
        }else{
            velocity = CGPointZero
            stopZombieAnimation()
        }
        
        //code for zombie to keep moving
//        moveSprite(zombie1, velocity: velocity)
//        rotateSprite(zombie1, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec)
        
        boundsCheckZombie()
    }
    
    override func didEvaluateActions() {
        checkCollisions()
    }
    
    //MARK: Zombie movement methods
    func moveZombieToward(location:CGPoint){ //updates zombie velocity
        startZombieAnimation()
        
        let offset = location - zombie1.position
        
        //unit vector
        let direction = offset.normalized()
        
        //velocity vector
        velocity = direction * CGFloat(zombieMovePointsPerSec)
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
        let amountToMove = velocity * CGFloat(dt)
        sprite.position += amountToMove
    }
    
    func rotateSprite(sprite:SKSpriteNode, direction:CGPoint, rotateRadiansPerSec:CGFloat){
        let shortest = shortestAngleBetweenTwoAngles(sprite.zRotation, angle2: direction.angle)
        
        let amountToRotate = min(rotateRadiansPerSec * CGFloat(dt), abs(shortest))
        sprite.zRotation += shortest.sign() * amountToRotate
    }
    
    //MARK: spawn methods
    func spawnEnemy(){
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.name = "enemy"
        enemy.position = CGPoint(x: size.width + enemy.size.width/2, y: CGFloat.random(min: CGRectGetMinY(playableRect) + enemy.size.height/2, max: CGRectGetMaxY(playableRect) - enemy.size.height/2))
        addChild(enemy)
        
        let actionMove = SKAction.moveToX(-enemy.size.width/2, duration: 2.0)
        let actionRemove = SKAction.removeFromParent()
        
        enemy.runAction(SKAction.sequence([actionMove, actionRemove]))
    }
    
    func spawnCat(){
        let cat = SKSpriteNode(imageNamed: "cat")
        cat.name = "cat"
        cat.position = CGPoint(
            x: CGFloat.random(min: CGRectGetMinX(playableRect),
                              max: CGRectGetMaxX(playableRect)),
            y: CGFloat.random(min: CGRectGetMinY(playableRect),
                              max: CGRectGetMaxY(playableRect)))
        cat.setScale(0)
        cat.zRotation = -pi / 16.0
        addChild(cat)
        
        let appear = SKAction.scaleTo(1.0, duration: 0.5)
        let leftWiggle = SKAction.rotateByAngle(pi/8.0, duration: 0.5)
        let rightWiggle = leftWiggle.reversedAction()
        let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
        
        let scaleUp = SKAction.scaleBy(1.2, duration: 0.25)
        let scaleDown = scaleUp.reversedAction()
        let fullScale = SKAction.sequence(
            [scaleUp, scaleDown, scaleUp, scaleDown])
        
        let group = SKAction.group([fullScale, fullWiggle])
        let groupWait = SKAction.repeatAction(group, count: 10)
        let disappear = SKAction.scaleTo(0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()
        
        let actions = [appear, groupWait, disappear, removeFromParent]
        cat.runAction(SKAction.sequence(actions))
    }

    //MARK: Touch handling methods
    func sceneTouched(touchLocation:CGPoint){
        moveZombieToward(touchLocation)
        lastTouchLocation = touchLocation
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
    
    //MARK: collision methods
    func zombieHitCat(cat: SKSpriteNode) {
        cat.removeFromParent()
        runAction(catCollisionSound)
    }
    func zombieHitEnemy(enemy: SKSpriteNode) {
        enemy.removeFromParent()
        runAction(enemyCollisionSound)
    }
    
    func checkCollisions() {
        //check cat collisions
        var hitCats: [SKSpriteNode] = []
        enumerateChildNodesWithName("cat"){ node, _ in
        let cat = node as! SKSpriteNode
        if CGRectIntersectsRect(cat.frame, self.zombie1.frame){
        hitCats.append(cat)
        }
        
        }
        for cat in hitCats{
            zombieHitCat(cat)
        }
        
        //check enemy collisions
        var hitEnemies: [SKSpriteNode] = []
        enumerateChildNodesWithName("enemy") { node, _ in
            let enemy = node as! SKSpriteNode
            if CGRectIntersectsRect(CGRectInset(enemy.frame, 20, 20), self.zombie1.frame){
            hitEnemies.append(enemy)
            }
        }
        
        for enemy in hitEnemies{
            zombieHitEnemy(enemy)
        }
        
    }
    
    //MARK: animation methods
    func startZombieAnimation(){
        if zombie1.actionForKey("animation") == nil{
            zombie1.runAction(SKAction.repeatActionForever(zombieAnimation), withKey: "animation")
        }
    }
    
    func stopZombieAnimation(){
        zombie1.removeActionForKey("animation")
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
