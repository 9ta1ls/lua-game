local player = {}

function player.load(world)
    player.x = 480
    player.y = 480
    player.speed = 100
    player.health = 50
    player.radius = 10
    player.type = "player"
    player.xp = 50
    player.max_xp = 100
    
    player.collider = world:newCollider("Circle", {player.x, player.y, player.radius})
    player.collider:getBody():setUserData(player)

end

function player.update(dt)
    local dx, dy = 0 ,0

    
    if love.keyboard.isDown('w') then
        dy = player.speed * -1
    end

    if love.keyboard.isDown('a') then
        dx = player.speed * -1
    end

    if love.keyboard.isDown('s') then
        dy = player.speed
      end

    if love.keyboard.isDown('d') then
        dx = player.speed 
      end

    player.collider:setLinearVelocity(dx , dy )
    player.x = player.collider:getX()
    player.y = player.collider:getY()

end

function player.draw()
    love.graphics.setColor(1, 1, 1) -- Білий колір
    love.graphics.circle('fill', player.x, player.y , player.radius)

    --hp bar
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle('fill', player.x - 15 , player.y - 20, 30, 4)
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle('fill', player.x - 15 , player.y - 20, player.health * 0.6 , 4)



    love.graphics.setColor(1, 1, 1)
    

end




return player