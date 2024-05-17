import "CoreLibs/crank"
import "CoreLibs/graphics"

local gfx = playdate.graphics
local sfx = playdate.sound
local btn = playdate.buttonIsPressed

-- load assets
local backgroundImage = gfx.image.new("image/bg")
local hitSound = sfx.sampleplayer.new("sound/paddle_hit")
local clinkSound = sfx.sampleplayer.new("sound/wall_clink")
local deathSound = sfx.sampleplayer.new("sound/death")

-- game state
local started = false
local lives = 3
local score = 0

-- paddle state
local paddlePosition = 150
local paddleWidth = 100
local paddleHeight = 14

-- ball state
local ballX = 150
local ballY = 150
local ballRadius = 10
local speedX = 4
local speedY = 4
local speedMtply = 1.0

function checkCollision()
    local ballDistanceX = math.abs(ballX - paddlePosition - paddleWidth/2)
    local ballDistanceY = math.abs(ballY - 220 - paddleHeight/2)

    if ballDistanceX > (paddleWidth/2 + ballRadius) or ballDistanceY > (paddleHeight/2 + ballRadius) then
        return false
    end

    if ballDistanceX <= (paddleWidth/2) or ballDistanceY <= (paddleHeight/2) then
        return true
    end

    local cornerDistance = (ballDistanceX - paddleWidth/2)^2 + (ballDistanceY - paddleHeight/2)^2
    return cornerDistance <= (ballRadius^2)
end

function setNewGameState() local paddlePosition = 150
    score = 0
    paddlePosition = 150
    ballX = 150
    ballY = 150
    speedX = 4
    speedY = 4
    speedMtply = 1.0
    started = true
end
    

function playdate.update()
    -- gfx.setColor(gfx.kColorWhite)
    -- gfx.fillRect(0, 0, 400, 240)
    backgroundImage:draw(0, 0)
    
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRoundRect(paddlePosition, 220, paddleWidth, paddleHeight, 10, 10)
    
    if started then
        gfx.fillCircleAtPoint(ballX, ballY, ballRadius)
        
        if playdate.isCrankDocked then
             local change, acceleratedChange = playdate.getCrankChange()
             paddlePosition = paddlePosition + change
        end
        
        local speed = 5
        
        if btn( playdate.kButtonB ) then
            speed = 10
        end
        
        if btn( playdate.kButtonLeft) then
            paddlePosition = paddlePosition - speed
        end
        if btn( playdate.kButtonRight) then
            paddlePosition = paddlePosition + speed
        end
        
        if paddlePosition < 0 then
            paddlePosition = 0
        end
        if paddlePosition > 300 then
            paddlePosition = 300
        end
        
        if ballX + ballRadius > 400 or ballX - ballRadius < 0 then
            clinkSound:play(1)
            speedX = -speedX
        end
        if ballY - ballRadius < 0 then
            clinkSound:play(1)
            speedY = -speedY
        end
        if ballY + ballRadius > 240 then
            deathSound:play(1)
            started = false
        end
        
        if checkCollision() then
            hitSound:play(1)
            score = score + 1
            speedMtply = speedMtply + 0.1
            speedY = -speedY
        end
        
        ballX = ballX + (speedX * speedMtply)
        ballY = ballY + (speedY * speedMtply)
        
    else
       gfx.drawText("Press A to Start...", 130, 120)
       if btn( playdate.kButtonA ) then
           setNewGameState()
       end
    end
    
    gfx.drawText(score, 6, 6)
end
