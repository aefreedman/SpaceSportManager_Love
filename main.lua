--[[
Copyright (c) 2015 by Aaron E. Freedman

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

Except as contained in this notice, the name(s) of the above copyright holders
shall not be used in advertising or otherwise to promote the sale, use or
other dealings in this Software without prior written authorization.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]--

-- ME stuff
Ship = {}
Planet = {}

-- notes
-- 255 132 121 peach
-- 205 81 232 purple
-- 79 88 255 blue
-- 81 216 232 light blue 
-- 96 255 130 green

-- SHIP
function Ship:new()
	newObj = { x = 1, y = 1, xVel = 0, yVel = 0 }
	self.__index = self
	return setmetatable(newObj, self)
end

function Ship:move(dt)
	self.x = self.x + self.xVel * dt
	self.y = self.y + self.yVel * dt
end

function Ship:draw()
	love.graphics.setColor(255, 132, 121, 255)
	love.graphics.rectangle('fill', ship.x, ship.y, 4, 4)
end

-- PLANET

function Planet:new(_x, _y, _r)
	newObj = { x = _x, y = _y, r = _r }
	self.__index = self
	return setmetatable(newObj, self)
end

function Planet:draw()
	love.graphics.setColor(125, 125, 125, 65)
	love.graphics.circle('fill', self.x, self.y, self.r * 4, 16)
	love.graphics.setColor(81, 216, 130, 255)
	love.graphics.circle('fill', self.x, self.y, self.r, 16)
end



-- Collision

HC = require 'lib/hardoncollider'
local text = {}

-- this is called when two shapes collide
function on_collision(dt, shape_a, shape_b, mtv_x, mtv_y)
    text[#text+1] = string.format("Colliding. mtv = (%s,%s)", mtv_x, mtv_y)
end

-- this is called when two shapes stop colliding
function collision_stop(dt, shape_a, shape_b)
    text[#text+1] = "Stopped colliding"
end

-- LOVE stuff					
function love.load()
	planet = Planet:new(50, 50, 10)
	ship = Ship:new()

	Collider = HC(100, on_collision, collision_stop)
    
    -- add a rectangle to the scene
    shipCollider = Collider:addRectangle(ship.x, ship.y, 4, 4)

    -- add a circle to the scene
    planetCollider = Collider:addCircle(planet.x, planet.y, planet.r)

	love.window.setTitle("Space Sport Manager")
    love.window.setMode(800, 600, {resizable=true, vsync=false, minwidth=400, minheight=300})
    ship.xVel = 10
    ship.yVel = 10
end

function love.update(dt)
	ship:move(dt)
	shipCollider:moveTo(ship.x, ship.y)

    -- check for collisions
    Collider:update(dt)

    while #text > 40 do
        table.remove(text, 1)
    end
end

function love.draw()
	ship:draw()
	planet:draw()

	    -- print messages
    for i = 1,#text do
        love.graphics.setColor(255,255,255, 255 - (i-1) * 6)
        love.graphics.print(text[#text - (i-1)], 10, i * 15)
    end
end
