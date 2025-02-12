local enemy = {}



function enemy.load()

end

function enemy.update(player, dt, world)
    create_enemy(player, world)

    for i = #enemy_table, 1, -1 do
        local enemy = enemy_table[i]    
        if enemy.toRemove then
            table.remove(enemy_table, i)
        end
    end

end

function enemy.draw()
    for _, enemy in ipairs(enemy_table) do
        love.graphics.setColor(1, 0 , 0)
        love.graphics.rectangle('fill', enemy.x - 8, enemy.y - 8, 16, 16)
    end
end

function moveEnemy(enemy, player)
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




function create_enemy(player, world)
    local enemy_x, enemy_y
    repeat
        enemy_x = math.random(player.x - 500, player.x + 500)
        enemy_y = math.random(player.y - 500, player.y + 500)
    until math.sqrt((enemy_x - player.x)^2 + (enemy_y - player.y)^2) > 400
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
        moveEnemy(enemy, player)
    end
end

return enemy