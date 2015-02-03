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

-- units are on the kilo-scale

local ship = {}
local Vector = require 'lib.hump.vector'
local tween = require 'lib.tween.tween'
-- local xVelTween = tween.new(1, Shi )

local Ship = {}
local Ship_mt = {__index = Ship}

-- Public interface

function ship.new(_x, _y, _mass, _fuel)
	return setmetatable({ 
		pos = Vector(_x, _y),
		v = Vector(0, 0),
		f = Vector(0, 0),
		accel = Vector(0, 0),
		dir = Vector(0, 0),
		collider = Collider:addRectangle(_x, _y, 4, 4),
		target,
		mass = _mass,
		power = 30000000,
		pVel = Vector(0, 0),
		fuel = _fuel
	}, Ship_mt)
end

function Ship:move(dt)
	self:calculateDirectionToTarget()
	if self.fuel > 0 then
		self:impulse(1.0, dt)
	end
	self.accel = self.f / self.mass * dt
	self.v = self.v + self.accel * dt
	-- self.v = self.v * 0.990 -- damping isn't really the best solution long-term but its the fastest solution short-term; 
							--need more logic for making the ship adjust it's thrust to maneuver properly
	self.pos = self.pos + self.v * dt
	self.collider:moveTo(self.pos.x, self.pos.y)
	self.f = Vector(0, 0)

end

function Ship:impulse(percentageOfThrust, dt)
	self.f = self.f + self.dir * self.power * percentageOfThrust
	local fuelUse = 8333 * dt
	self.fuel = self.fuel - fuelUse
	self.mass = self.mass - fuelUse
	print(self.fuel)
end

function Ship:stop()

end

function Ship:draw()
	love.graphics.setColor(255, 132, 121, 255)
	love.graphics.circle('fill', self.pos.x, self.pos.y, 4) -- body

	love.graphics.setColor(0, 255, 125, 155)
	love.graphics.line(self.pos.x, self.pos.y, self.pos.x + self.v.x, self.pos.y + self.v.y) -- velocity
	love.graphics.circle('line', self.pos.x + self.v.x, self.pos.y + self.v.y, 4, 8)

	love.graphics.setColor(255, 0, 0, 155)
	love.graphics.line(self.pos.x, self.pos.y, self.pos.x + self.accel.x, self.pos.y + self.accel.y) -- accel
	love.graphics.circle('line', self.pos.x + self.v.x, self.pos.y + self.v.y, 1, 8)

	-- if target then
	love.graphics.setColor(255, 255, 255)
		love.graphics.circle('fill', self.target.x, self.target.y, 2, 16)
	-- end
end

function Ship:setTarget(location)
	self.target = location
end

function Ship:calculateDirectionToTarget()
	local t = Vector(self.target.x, self.target.y)
	local temp = t - self.pos
	self.dir = temp:normalized()
	-- print('ship-target vector ' .. self.dir.x, self.dir.y)
end

return ship