
function shoot(player_x , player_y, dt)
    if #enemy_table == 0 then
        return 
    end

    interval = 1

    if bullet_timer >= interval then
       bullet_timer = 0 

        --find nearest enemy 
        local nearest_enemy
        local smallest_lenght = 10000
        for _, enemy in ipairs(enemy_table) do
            local vector_length = math.sqrt((enemy.x - player_x)^2 + (enemy.y - player_y)^2)
            if smallest_lenght > vector_length then
                smallest_lenght = vector_length
                nearest_enemy = enemy
            end
        end

        if nearest_enemy then
            local dx = nearest_enemy.x - player_x 
            local dy = nearest_enemy.y - player_y

            -- Нормалізація вектора напряму
            local length = math.sqrt(dx * dx + dy * dy)
            if length > 0 then
                dx = dx / length
                dy = dy / length
            end

            local offset = player.radius + 10
            -- Створення кулі
            local bullet = {
                x = player_x + dx * offset,
                y = player_y + dy * offset,
                speed = 450,
                dx = dx,
                dy = dy,
                radius = 2,
                type = "bullet",
                toRemove = false
            }

            bullet.collider = world:newCollider("Circle", {bullet.x, bullet.y, bullet.radius}, bullet)
            bullet.collider:setLinearVelocity(bullet.dx * bullet.speed, bullet.dy * bullet.speed)
            bullet.collider:getBody():setUserData(bullet)


            table.insert(bullet_table, bullet)

        end
    end
    
end


function create_enemy(player_x, player_y)
    local enemy_x, enemy_y
    repeat
        enemy_x = math.random(player_x - 500, player_x + 500)
        enemy_y = math.random(player_y - 500, player_y + 500)
    until math.sqrt((enemy_x - player_x)^2 + (enemy_y - player_y)^2) > 400
    interval = 0.5
    if enemy_timer >= interval then
        enemy = {
        x = enemy_x, 
        y = enemy_y, 
        speed = 120,
        type = "enemy",
        toRemove = false
    }
       enemy.collider = world:newCollider("Circle", {enemy.x, enemy.y, 10})
       enemy.collider:getBody():setUserData(enemy)
    

       table.insert(enemy_table, enemy)
       enemy_timer = 0 
    end

    for _, enemy in ipairs(enemy_table) do
        moveEnemy(enemy)
    end
end


function moveEnemy(enemy)
    -- Вектор напрямку
    local dx = player.x - enemy.x
    local dy = player.y - enemy.y

    -- Нормалізація (щоб ворог рухався рівномірно)
    local length = math.sqrt(dx * dx + dy * dy)
    if length > 0 then
        dx = dx / length
        dy = dy / length
    end

    -- Рух ворога

    enemy.collider:setLinearVelocity(dx * enemy.speed, dy * enemy.speed);
    enemy.x = enemy.collider:getX()
    enemy.y = enemy.collider:getY()
end



function beginContact(a, b, coll)
    local objA = a:getBody():getUserData()
    local objB = b:getBody():getUserData()
    if not objA or not objB then 
        return 
    end
    print("Collision between:", objA.type, "and", objB.type)

    if (objA.type == "bullet" and objB.type == "enemy") or
       (objB.type == "bullet" and objA.type == "enemy") then
        objA.toRemove = true
        objB.toRemove = true
        a:destroy()
        b:destroy()
    elseif (objA.type == "player" and objB.type == "enemy") or
           (objB.type == "player" and objA.type == "enemy") then
        if objA.health then
            objA.health = objA.health - 5 
        else
            objB.health = objB.health - 5
        end
    end
end





function love.load()


    
    window_height = 600
    window_width = 800
    camera = require 'lib/camera'
    cam = camera()
    cam.scale = 1.15

    sti = require 'lib/sti'
    game_map = sti('maps/map.lua')

    bf = require('lib/breezefield')
    world = bf.newWorld(0,0, true)
    world:setCallbacks(beginContact)


    player = {
        x = 480, 
        y = 480 , 
        speed  = 100,
        health = 50,
        radius = 10,
        type = "player"
    }

    player.collider = world:newCollider("Circle", {player.x, player.y, player.radius})
    player.collider:getBody():setUserData(player)


    bullet_table = {}
    enemy_table = {}

    bullet_timer = 0
    enemy_timer = 0

end


function love.update(dt)
    world:update(dt)

    local dx, dy = 0, 0

    bullet_timer = bullet_timer + dt
    enemy_timer = enemy_timer + dt

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

    shoot(player.x, player.y, dt)
    

    create_enemy(player.x, player.y)

    for _, bullet in ipairs(bullet_table) do
        bullet.x = bullet.collider:getX()
        bullet.y = bullet.collider:getY()
    end

    for i = #bullet_table, 1, -1 do
        local bullet = bullet_table[i]
        if bullet.toRemove then
            table.remove(bullet_table, i)
        end
    end

    for i = #enemy_table, 1, -1 do
        local enemy = enemy_table[i]
        if enemy.toRemove then
            table.remove(enemy_table, i)
        end
    end

    cam:lookAt(player.x * cam.scale, player.y * cam.scale)

end

function love.draw()
    cam:attach()
        love.graphics.scale(cam.scale, cam.scale);
        game_map:drawLayer(game_map.layers["ground"])
        game_map:drawLayer(game_map.layers["objects"])
   

        love.graphics.setColor(1, 1, 1) -- Білий колір
        love.graphics.circle('fill', player.x, player.y , player.radius)

        for _, bullet in ipairs(bullet_table) do
            love.graphics.circle('fill', bullet.collider:getX(), bullet.collider:getY(), 2)
        end

        for _, enemy in ipairs(enemy_table) do
            love.graphics.setColor(1, 0 , 0)
            love.graphics.rectangle('fill', enemy.x - 8, enemy.y - 8, 16, 16)
        end

        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle('fill', player.x - 15 , player.y - 20, 30, 4)
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle('fill', player.x - 15 , player.y - 20, player.health * 0.6 , 4)
        love.graphics.setColor(1, 1, 1)

    cam:detach()
end



