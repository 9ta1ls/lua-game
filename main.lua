
local player = require 'player'

local bullet = require 'bullet'

local enemy = require 'enemy'

local xp = require 'xp'


function beginContact(a, b, coll)
    local objA = a:getBody():getUserData()
    local objB = b:getBody():getUserData()
    if not objA or not objB then 
        return 
    end
    print("Collision between:", objA.type, "and", objB.type)

    if (objA.type == "bullet" and objB.type == "enemy") or
       (objB.type == "bullet" and objA.type == "enemy") then
        if objA.type == "enemy" then
            xp.createXP(objA)
            print(objA)
        else
            xp.createXP(objB)
        end
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

    elseif (objA.type == "player" and objB.type == "xp") or
            (objB.type == "player" and objA.type == "xp") then
        if objA.xp then
            objA.xp = objA.xp - 5 
        else
            objB.xp = objB.xp - 5
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

    xp_table = {}
    bullet_table = {}
    enemy_table = {}
 
    player.load(world)
    bullet.load()

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

        xp.update(dt, world)
        
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
        xp.draw()
        world:draw()

    cam:detach()
    drawXPBar()

end



function drawXPBar()
    local bar_width = love.graphics.getWidth()  -- Повна ширина екрану
    local bar_height = 15   -- Висота полоски
    local bar_x = 0         -- Початок з лівого краю
    local bar_y = 0      -- Відступ від верху

    local xp_percent = player.xp / player.max_xp  -- Відсоток досвіду

    -- Фон полоски (чорний)
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", bar_x, bar_y, bar_width, bar_height)

    -- Заповнена частина досвідом (синя)
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", bar_x, bar_y, bar_width * xp_percent, bar_height)

    -- Повертаємо стандартний колір
    love.graphics.setColor(1, 1, 1)
end

