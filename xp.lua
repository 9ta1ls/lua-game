local xp = {}

function xp.createXP(enemy)
    local newXP = {}
    newXP.x = enemy.x
    newXP.y = enemy.y
    newXP.type = "xp"
    newXP.toRemove = false    

    
    table.insert(xp_table, newXP)

end

function xp.spawnXP(world)
    for _, xp in ipairs(xp_table) do
        print("meeeeeow")
        if not xp.collider then
            xp.collider = world:newCollider("Rectangle", {xp.x, xp.y, 8, 10})
            print("meow")
            xp.collider:getBody():setUserData(xp)
        end
    end
end

function xp.update(dt, world)
    xp.spawnXP(world)

    
    for i = #xp_table, 1, -1 do
        local xp = xp_table[i]    
        if xp.toRemove then
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