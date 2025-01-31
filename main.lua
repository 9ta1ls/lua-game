
function shoot(player_x, player_y)
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

            -- Створення кулі
            local bullet = {
                x = player_x,
                y = player_y,
                radius = 2,
                speed = 350,
                dx = dx,
                dy = dy,
                type = "bullet"
            }

            table.insert(bullet_table, bullet)
            world:add(bullet, bullet.x, bullet.y ,bullet.radius * 2, bullet.radius *2)
            local newX, newY = player.x + dx , player.y + dy
            local actualX, actualY, cols, len = world:move(bullet, newX, newY, bulletFilter)
        
            bullet.x, bullet.y = actualX, actualY
        end
    end
    
end


function create_enemy(player_x, player_y, dt)
    local enemy_x, enemy_y
    repeat
        enemy_x = math.random(player_x - 500, player_x + 500)
        enemy_y = math.random(player_y - 500, player_y + 500)
    until math.sqrt((enemy_x - player_x)^2 + (enemy_y - player_y)^2) > 400
    interval = 1
    if enemy_timer >= interval then
       enemy = {
           x = enemy_x, 
           y = enemy_y,
           h = 16,
           w = 16,
           speed = 70,
           type = "enemy"
        }
       table.insert(enemy_table, enemy)
       world:add(enemy, enemy_x, enemy_y, enemy.w, enemy.h)
       enemy_timer = 0 
    end

    for _, enemy in ipairs(enemy_table) do
        moveEnemy(enemy, dt)
    end
end


function moveEnemy(enemy, dt)
    -- Вектор напрямку
    local dx = player.x - enemy.x
    local dy = player.y - enemy.y

    

    -- Нормалізація (щоб ворог рухався рівномірно)
    local length = math.sqrt(dx * dx + dy * dy)
    if length > 0 then
        dx = dx / length
        dy = dy / length
    end

--[[     -- Рух ворога
    enemy.x = enemy.x + dx * enemy.speed
    enemy.y = enemy.y + dy * enemy.speed ]]

    local newX, newY = enemy.x + dx * enemy.speed * dt, enemy.y + dy * enemy.speed * dt
    local actualX, actualY, cols, len = world:move(enemy, newX, newY, enemyFilter)

    enemy.x, enemy.y = actualX, actualY
    
end

function enemyFilter(item, other)
    if other.type == "player" then
        return "cross" 
    elseif other.type == "bullet" then
        return "bounce" 
    elseif other.type == "enemy" then
        return "slide"
    else
        return "cross"
    end
end

function playerFilter(item, other)
    if other.type == "enemy" then
        return "cross" 
    else
        return "cross" 
    end
end

function bulletFilter(item, other)
    if other.type == "enemy" then
        return "touch" 
    else
        return "cross" 
    end
end

--move player 
function updatePlayer(dt)
    local dx, dy = 0, 0

    if love.keyboard.isDown('w') then
        dy = -player.speed * dt
    end
    if love.keyboard.isDown('a') then
        dx = -player.speed * dt
    end
    if love.keyboard.isDown('s') then
        dy = player.speed * dt
    end
    if love.keyboard.isDown('d') then
        dx = player.speed * dt
    end

    local newX, newY = player.x + dx, player.y + dy
    local actualX, actualY, cols, len = world:move(player, newX, newY, playerFilter)

    player.x, player.y = actualX, actualY
end
--



function love.load()

    bump = require 'lib/bump'
    world = bump.newWorld(16) 

    window_height = 600
    window_width = 800
    camera = require 'lib/camera'
    cam = camera()
    cam.scale = 1.15

    sti = require 'lib/sti'
    game_map = sti('maps/map.lua')


    player = {
        x = 480, 
        y = 480, 
        radius = 10,
        speed  = 100,
        health = 30,
        type = "player"
    }

    world:add(player, player.x, player.y, player.radius * 2, player.radius * 2)

    bullet_table = {}
    enemy_table = {}

    bullet_timer = 0
    enemy_timer = 0

end


function love.update(dt)

    bullet_timer = bullet_timer + dt
    enemy_timer = enemy_timer + dt

    updatePlayer(dt)

    shoot(player.x, player.y)

    create_enemy(player.x, player.y, dt)

    for i, bullet in ipairs(bullet_table) do
        bullet.x = bullet.x + bullet.dx * bullet.speed * dt
        bullet.y = bullet.y + bullet.dy * bullet.speed * dt
    end

    cam:lookAt(player.x * cam.scale, player.y * cam.scale)

end

function love.draw()
    cam:attach()
        love.graphics.scale(cam.scale, cam.scale);
        game_map:drawLayer(game_map.layers["ground"])
        game_map:drawLayer(game_map.layers["objects"])

        --draw player
        love.graphics.setColor(1, 1, 1)
        love.graphics.circle('fill', player.x, player.y , player.radius)

        --draw bullets
        for _, bullet in ipairs(bullet_table) do
            love.graphics.circle('fill', bullet.x, bullet.y, bullet.radius)
        end

        --draw enemies
        for _, enemy in ipairs(enemy_table) do
            love.graphics.setColor(1, 0 , 0)
            love.graphics.rectangle('fill', enemy.x - 8, enemy.y - 8, enemy.w , enemy.h)
        end

        --draw player health bar 
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle('fill', player.x - 15 , player.y - 20, 30, 4)
        love.graphics.setColor(1, 0, 0)

        --draw player health bar background
        love.graphics.rectangle('fill', player.x - 15 , player.y - 20, player.health * 0.6 , 4)
        love.graphics.setColor(1, 1, 1)
    cam:detach()
end



