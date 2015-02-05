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

-- Enables concurrent stdout
io.stdout:setvbuf("no")

-- Dependencies
local Vector = require 'lib.hump.vector'
local Rocket = require 'rocket'
local Camera = require 'lib.hump.camera'
local HC = require 'lib/hardoncollider'

-- Globals
rocketTargetIndex = 1
canChange = true
meterToPixelRatio = 250 -- :1
debug = false
elapsedTime = 0

-- Game Variables
local Planet = {}
local text = {}
local planets = {}
local rocket

local numberOfPlanets = 4
local drawGrid = false
local zoom = 1


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


-- LOVE stuff					
function love.load()

	min_dt = 1/60
	next_time = love.timer.getTime()


	love.window.setTitle("Space Sport Manager")
    love.window.setMode(1280, 720, {resizable=true, vsync=false, minwidth=400, minheight=300})

	Collider = HC(100, on_collision, collision_stop)

	for i = 1 , numberOfPlanets do
		-- planets[i] = Planet:new(love.window.getWidth() * love.math.random(-200, 200) / 100, love.window.getHeight() * love.math.random(-200, 200) / 100, love.math.random(5, 20))
		planets[i] = Planet:new(love.window.getWidth() * love.math.random(-200, 200) / 800, love.window.getHeight() * love.math.random(-200, 200) / 800, love.math.random(5, 20))

	end

	rocket = Rocket.new(50, 50)
	-- rocket:setTarget(Vector(love.window.getWidth(), love.window.getHeight()))
	rocket:setTarget(planets[1])
	rocket:calculateDirectionToTarget()
	cam = Camera(100, 100, zoom, 0)

end

function love.update(dt)
	next_time = next_time + min_dt
	elapsedTime = elapsedTime + dt

    checkKeyDown(dt)


	rocket:update(dt)

    -- check for collisions
    Collider:update(dt)



    while #text > 40 do
        table.remove(text, 1)
    end

	love.window.setTitle("Space Sport Manager | fps:" .. love.timer.getFPS() .. " | " .. string.format("%.2f", elapsedTime))
end

-- DRAW REGION

function love.draw()
	cam:lookAt(rocket.pos.x, rocket.pos.y)
	cam:draw(drawWorld)
	drawGUI()

   local cur_time = love.timer.getTime()
   if next_time <= cur_time then
      next_time = cur_time
      return
   end
   love.timer.sleep(next_time - cur_time)

end

function drawWorld()
	rocket:draw()

	for k,v in pairs(planets) do
		v:draw()
	end
end

function drawGUI()
    if drawGrid then
    	DrawGrid()
    end

    -- outputs info about the rocket
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print(
    	"pos=<" ..string.format("%.0f", rocket.pos.x) .. ', ' .. string.format("%.0f",rocket.pos.y) ..
    	">, fuel mass rem. =" .. string.format("%.0f", rocket.fuel) ..
    	'kg, accel=' .. string.format("%.2f", rocket.accel:len()) ..
    	' m/s^2, vel=' .. string.format("%.2f", rocket.v:len()) .. ' m/s' ..
    	' remaining burn time = ' .. string.format("%.2f", rocket.remainingBurnTime) .. "s" ..
    	-- ' fuel use = ' .. string.format("%.2f", rocket.fuelUse) ..
    	' -- throttle =' .. string.format("%.2f", rocket.throttle)
    	)

    -- print messages
    for i = 1,#text do
        love.graphics.setColor(255,255,255, 255 - (i-1) * 6)
        love.graphics.print(text[#text - (i-1)], 10, i * 15)
    end
end

function DrawGrid()
    love.graphics.setColor(0, 255, 0, 55)
    for i=1,love.graphics.getHeight()/40/zoom + 1 do
    	love.graphics.line(0, 40*zoom * i, love.graphics.getWidth(), 40*zoom * i)
    end

    for i=1,love.graphics.getWidth()/40/zoom + 1 do
    	love.graphics.line(40*zoom * i, 0, 40*zoom * i, love.graphics.getHeight())
    end
end

-- COLLISION LOGIC

-- this is called when two shapes collide
function on_collision(dt, shape_a, shape_b, mtv_x, mtv_y)
	local other
	if shape_a == rocket.collider then
		other = shape_a
	elseif shape_b == rocket.collider then
		other = shape_b
	else
		return
	end

	if canChange == false then
		return
	end

	-- rocket:stop()
	if rocketTargetIndex < table.getn(planets) then
		rocketTargetIndex = 1 + rocketTargetIndex
	elseif rocketTargetIndex == table.getn(planets) then
		rocketTargetIndex = 1
	end

		rocket:setTarget(planets[rocketTargetIndex])
		rocket:calculateDirectionToTarget()
		canChange = false

    -- text[#text+1] = string.format("Colliding. mtv = (%s,%s)", mtv_x, mtv_y)
end

-- this is called when two shapes stop colliding
function collision_stop(dt, shape_a, shape_b)
		local other
	if shape_a == rocket.collider then
		other = shape_a
	elseif shape_b == rocket.collider then
		other = shape_b
	else
		return
	end
	canChange = true
    -- text[#text+1] = "Stopped colliding"
end

-- CONTROL REGION --

function checkKeyDown(dt)
	if love.keyboard.isDown('[') then
		rocket.throttle = rocket.throttle - 0.01
	end

	if love.keyboard.isDown(']') then
		rocket.throttle = rocket.throttle + 0.01
	end

	if love.keyboard.isDown(' ') then
		rocket:airbrake(dt)
	end
end

function love.keypressed(key, u)

	if key == "z" then
		-- rocket:impulse(1.0)
	end

	if key == "d" then
		debug = not debug
	end

	if key == "g" then
		drawGrid = not drawGrid
	end

	if key == "-" then
		zoom = zoom / 2
		cam:zoom(0.5)
	end

	if key == "=" then
		zoom = zoom * 2
		cam:zoom(2)
	end

	-- if key == "[" then
	-- 	rocket.throttle = rocket.throttle - 0.01
	-- end

	-- if key == "]" then
	-- 	rocket.throttle = rocket.throttle + 0.01
	-- end

	if key == "0" then
		rocket.throttle = 0
	end

	if key == "1" then
		rocket.throttle = 1
	end

   --Debug
   if key == "a" then --set to whatever key you want to use
      debug.debug()
   end
end


