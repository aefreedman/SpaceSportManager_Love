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

io.stdout:setvbuf("no")

-- ME stuff
local Ship = {}
local Planet = {}
local vector = require 'lib/HardonCollider/vector-light'

-- Game Variables
local numberOfPlanets = 4
local planets = {}
local ship
local shipSpeed = 5

-- notes
-- 255 132 121 peach
-- 205 81 232 purple
-- 79 88 255 blue
-- 81 216 232 light blue 
-- 96 255 130 green

-- SHIP

function Ship:new(_x, _y)
	newObj = { x = _x, y = _y, xVel = 0, yVel = 0, collider, target }
	self.__index = self
	self.collider = Collider:addRectangle(_x, _y, 4, 4)
	return setmetatable(newObj, self)
end

function Ship:move(dt)
	self.x = self.x + self.xVel * dt
	self.y = self.y + self.yVel * dt
	self.collider:moveTo(self.x, self.y)
end

function Ship:stop()
	if self.xVel == 0 then
		if self.yVel == 0 then
			return
		end
	end
	self.xVel = 0
	self.yVel = 0
	print('stopping')
end

function Ship:draw()
	love.graphics.setColor(255, 132, 121, 255)
	love.graphics.rectangle('fill', self.x, self.y, 4, 4)
	love.graphics.setColor(0, 255, 125, 255)
	love.graphics.circle('line', self.x + self.xVel, self.y + self.yVel, 1, 8)
	if target then
		love.graphics.circle('line', self.target.x, self.target.y, self.target.r * 2, 16)
	end
end

function Ship:setTarget(location)
	self.target = location
end

function Ship:calculateVelocityToTarget()
	local dx, dy = vector.sub(self.target.x, self.target.y, self.x, self.y)
	self.xVel = dx / shipSpeed
	self.yVel = dy / shipSpeed
	print('ship-target vector ' .. dx, dy)
end
-- PLANET

function Planet:new(_x, _y, _r)
	newObj = { x = _x, y = _y, r = _r, collider }
	self.__index = self
    self.collider = Collider:addCircle(_x, _y, _r)
	return setmetatable(newObj, self)
end

function Planet:draw()
	love.graphics.setColor(125, 125, 125, 65)
	love.graphics.circle('line', self.x, self.y, self.r * 4, 16)
	love.graphics.setColor(81, 216, 130, 255)
	love.graphics.circle('line', self.x, self.y, self.r, 16)
end



-- Collision

HC = require 'lib/hardoncollider'
local text = {}

-- this is called when two shapes collide
function on_collision(dt, shape_a, shape_b, mtv_x, mtv_y)
	local other
	if shape_a == ship.collider then
		other = shape_a
	elseif shape_b == ship.collider then
		other = shape_b
	else
		return
	end
	ship:stop()

    -- text[#text+1] = string.format("Colliding. mtv = (%s,%s)", mtv_x, mtv_y)
end

-- this is called when two shapes stop colliding
function collision_stop(dt, shape_a, shape_b)
    -- text[#text+1] = "Stopped colliding"
end

-- LOVE stuff					
function love.load()
	love.window.setTitle("Space Sport Manager")
    love.window.setMode(800, 600, {resizable=true, vsync=false, minwidth=400, minheight=300})

	Collider = HC(100, on_collision, collision_stop)

	for i = 1 , numberOfPlanets do
		planets[i] = Planet:new(love.window.getWidth() * love.math.random(), love.window.getHeight() * love.math.random(), love.math.random(5, 15))
	end

	ship = Ship:new(love.window.getWidth() * love.math.random(), love.window.getHeight() * love.math.random())

	ship:setTarget(planets[1])
	ship:calculateVelocityToTarget()


end

function love.update(dt)
	ship:move(dt)

    -- check for collisions
    Collider:update(dt)

    while #text > 40 do
        table.remove(text, 1)
    end
end

function love.draw()
	ship:draw()

	for k,v in pairs(planets) do
		v:draw()
	end

	    -- print messages
    for i = 1,#text do
        love.graphics.setColor(255,255,255, 255 - (i-1) * 6)
        love.graphics.print(text[#text - (i-1)], 10, i * 15)
    end
end
