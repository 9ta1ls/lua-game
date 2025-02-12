local bullet = {}

function shoot(player, dt)
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
            local vector_length = math.sqrt((enemy.x - player.x)^2 + (enemy.y - player.y)^2)
            if smallest_lenght > vector_length then
                smallest_lenght = vector_length
                nearest_enemy = enemy
            end
        end

        if nearest_enemy then
            local dx = nearest_enemy.x - player.x 
            local dy = nearest_enemy.y - player.y

            -- Нормалізація вектора напряму
            local length = math.sqrt(dx * dx + dy * dy)
            if length > 0 then
                dx = dx / length
                dy = dy / length
            end

            local offset = player.radius + 10
            -- Створення кулі
            local bullet = {
                x = player.x + dx * offset,
                y = player.y + dy * offset,
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

function bullet.load()
    bullet_timer = 0
end 

function bullet.update(player,dt)
    bullet_timer = bullet_timer + dt

    shoot(player, dt)

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

end

function bullet.draw()
    for _, bullet in ipairs(bullet_table) do
        love.graphics.circle('fill', bullet.collider:getX(), bullet.collider:getY(), 2)
    end

end

return bullet