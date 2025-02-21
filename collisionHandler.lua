local xp = require 'xp'

local collisionHandler = {}

function collisionHandler.enemyBullet(objA, objB)
    
    if objA.type == "enemy" then
        enemy = objA
        bullet  = objB
    else
        enemy = objB
        bullet  = objA
    end
    enemy.health = enemy.health  - bullet.damage
    if enemy.health <= 0 then
        xp.createXP(enemy)    
        enemy.toRemove = true
    end
    bullet.toRemove = true 
end


return collisionHandler