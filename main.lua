
local player = require 'player'

local bullet = require 'bullet'

local enemy = require 'enemy'

--[[ function create_enemy(player_x, player_y)
    local enemy_x, enemy_y
    repeat
        enemy_x = math.random(player_x - 500, player_x + 500)
        enemy_y = math.random(player_y - 500, player_y + 500)
    until math.sqrt((enemy_x - player_x)^2 + (enemy_y - player_y)^2) > 400
    interval = 0.7
    if enemy_timer >= interval then
        enemy = {
        x = enemy_x, 
        y = enemy_y, 
        speed = 100,
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
end ]]


--[[ function moveEnemy(enemy)
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
end ]]



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

    is_game_paused = false 
    
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

    player.load(world)
    bullet.load()

    bullet_table = {}
    enemy_table = {}
     enemy_timer = 0

end


function love.update(dt)

    if love.keyboard.isDown('p') then
        is_game_paused =  not is_game_paused
    end


    if is_game_paused == false then
        world:update(dt)

        if player.health <= 0 then 
            is_game_paused = true
        end

        local dx, dy = 0, 0

        enemy_timer = enemy_timer + dt

        player.update(dt)

        bullet.update(player, dt)

        enemy.update(player, dt, world)

--[[         create_enemy(player.x, player.y)
 ]]
--[[         for i = #bullet_table, 1, -1 do
            local bullet = bullet_table[i]
            if bullet.toRemove then
                table.remove(bullet_table, i)
            end
        end ]]

      

        cam:lookAt(player.x * cam.scale, player.y * cam.scale)

        end     
        
end

function love.draw()
    cam:attach()
        love.graphics.scale(cam.scale, cam.scale);
        game_map:drawLayer(game_map.layers["ground"])
        game_map:drawLayer(game_map.layers["objects"])
   
        
  
        enemy.draw()

        player.draw()
        bullet.draw()
    cam:detach()
end



