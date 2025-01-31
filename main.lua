
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
                speed = 3,
                dx = dx,
                dy = dy
            }

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
    interval = 1
    if enemy_timer >= interval then
       enemy = {x = enemy_x, y = enemy_y, speed = 0.35}
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
    enemy.x = enemy.x + dx * enemy.speed
    enemy.y = enemy.y + dy * enemy.speed
end


function love.load()
    window_height = 600
    window_width = 800
    camera = require 'lib/camera'
    cam = camera()
    cam.scale = 1.15

    sti = require 'lib/sti'
    game_map = sti('maps/map.lua')


    player = {
        x = 480, 
        y = 480 , 
        speed  = 0.6,
        health = 30
    }

    bullet_table = {}
    enemy_table = {}

    bullet_timer = 0
    enemy_timer = 0

end


function love.update(dt)

    bullet_timer = bullet_timer + dt
    enemy_timer = enemy_timer + dt

    if love.keyboard.isDown('w') then
        player.y = player.y - player.speed 
    end

    if love.keyboard.isDown('a') then
        player.x = player.x - player.speed 
    end

    if love.keyboard.isDown('s') then
        player.y = player.y + player.speed
    end

    if love.keyboard.isDown('d') then
        player.x = player.x + player.speed
    end

    shoot(player.x, player.y)

    create_enemy(player.x, player.y)

    for i, bullet in ipairs(bullet_table) do
        bullet.x = bullet.x + bullet.dx * bullet.speed
        bullet.y = bullet.y + bullet.dy * bullet.speed
    end

    cam:lookAt(player.x * cam.scale, player.y * cam.scale)

end

function love.draw()
    cam:attach()
        love.graphics.scale(cam.scale, cam.scale);
        game_map:drawLayer(game_map.layers["ground"])
        game_map:drawLayer(game_map.layers["objects"])

        love.graphics.setColor(1, 1, 1) -- Білий колір
        love.graphics.circle('fill', player.x, player.y , 10)

        for _, value in ipairs(bullet_table) do
            love.graphics.circle('fill', value.x, value.y, 2)
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



