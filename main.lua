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
local Ship = require 'ship'
local Planet = {}
-- local vector = require 'lib/HardonCollider/vector-light'

-- Game Variables
local numberOfPlanets = 4
local planets = {}
local ship
shipTargetIndex = 1
canChange = true

-- notes
-- 255 132 121 peach
-- 205 81 232 purple
-- 79 88 255 blue
-- 81 216 232 light blue 
-- 96 255 130 green

-- SHIP


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

	if canChange == false then
		return
	end

	-- ship:stop()
	if shipTargetIndex < table.getn(planets) then
		shipTargetIndex = 1 + shipTargetIndex
	elseif shipTargetIndex == table.getn(planets) then
		shipTargetIndex = 1
	end

		ship:setTarget(planets[shipTargetIndex])
		ship:calculateDirectionToTarget()
		canChange = false

    -- text[#text+1] = string.format("Colliding. mtv = (%s,%s)", mtv_x, mtv_y)
end

-- this is called when two shapes stop colliding
function collision_stop(dt, shape_a, shape_b)
		local other
	if shape_a == ship.collider then
		other = shape_a
	elseif shape_b == ship.collider then
		other = shape_b
	else
		return
	end
	canChange = true
    -- text[#text+1] = "Stopped colliding"
end

-- LOVE stuff					
function love.load()

	min_dt = 1/60
	next_time = love.timer.getTime()


	love.window.setTitle("Space Sport Manager")
    love.window.setMode(800, 600, {resizable=true, vsync=false, minwidth=400, minheight=300})

	Collider = HC(100, on_collision, collision_stop)

	for i = 1 , numberOfPlanets do
		planets[i] = Planet:new(love.window.getWidth() * love.math.random(), love.window.getHeight() * love.math.random(), love.math.random(5, 15))
	end

	ship = Ship.new(love.window.getWidth() * love.math.random(), love.window.getHeight() * love.math.random(), 1)

	ship:setTarget(planets[shipTargetIndex])
	ship:calculateDirectionToTarget()


end

function love.update(dt)
	next_time = next_time + min_dt
	ship:move(dt)

    -- check for collisions
    Collider:update(dt)

    while #text > 40 do
        table.remove(text, 1)
    end

	love.window.setTitle("Space Sport Manager " .. love.timer.getFPS())
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

   local cur_time = love.timer.getTime()
   if next_time <= cur_time then
      next_time = cur_time
      return
   end
   love.timer.sleep(next_time - cur_time)
end

function love.keypressed(key, u)

	if key == "z" then
		-- ship:impulse(1.0)
	end

   --Debug
   if key == "a" then --set to whatever key you want to use
      debug.debug()
   end
end
