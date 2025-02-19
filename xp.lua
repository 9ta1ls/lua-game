local xp = {}

function xp.createXP(enemy)
    local newXP = {}
    newXP.x = enemy.x
    newXP.y = enemy.y
    newXP.type = "xp"
    newXP.toRemove = false   
    newXP.speed = 200

    
    table.insert(xp_table, newXP)

end

function xpMove(xp, player)
    local dx = player.x - xp.x
    local dy = player.y - xp.y

    local length = math.sqrt(dx * dx + dy * dy)
    if length < 50 then
        if length > 0 then
            dx = dx / length
            dy = dy / length
        end
    
        xp.collider:setLinearVelocity(dx * xp.speed, dy * xp.speed);
        xp.x = xp.collider:getX()
        xp.y = xp.collider:getY()
    end
end

function xp.spawnXP(world)
    for _, xp in ipairs(xp_table) do
        if not xp.collider then
            xp.collider = world:newCollider("Rectangle", {xp.x, xp.y, 8, 10})
            xp.collider:getBody():setUserData(xp)
            xp.collider:setCategory(4)
        end
    end
end

function xp.update(dt, world, player)
    xp.spawnXP(world)

    for _, xp in ipairs(xp_table) do
        xpMove(xp, player)
    end

    for i = #xp_table, 1, -1 do
        local xp = xp_table[i]    
        if xp.toRemove then
            if xp.collider then
                xp.collider:destroy()
            end
            table.remove(xp_table, i)
        end
    end
end


function xp.draw()
    for _, xp in ipairs(xp_table) do
        love.graphics.setColor(0, 1 , 0)
        love.graphics.rectangle('fill', xp.x - 4 , xp.y - 5, 8, 10)
    end
end

return xp 