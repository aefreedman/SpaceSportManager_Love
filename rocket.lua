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

local rocket = {}
local Vector = require 'lib.hump.vector'
local tween = require 'lib.tween.tween'
-- local xVelTween = tween.new(1, Shi )

local Rocket = {}
local Rocket_mt = {__index = Rocket}

--[[ This is a Saturn V S-II rocket approximation
local emptyMass = 40100
local payloadMass = 0
local grossMass = 496200
local ratedThrust = 4400 * 1000 -- kN * 1000 = N
local specificImpulse = 421 -- seconds
local burnTime = 360
local flowRate = 240.7255 -- kg/sec
local numberOfEngines = 5
]]--

local emptyMass = 4010
local payloadMass = 0
local grossMass = 10000
local ratedThrust = 4400 * 1000 -- kN * 1000 = N
local specificImpulse = 421 -- seconds
local burnTime = 360
local flowRate = 24.7255 -- kg/sec
local numberOfEngines = 5

-- Public interface

function rocket.new(_x, _y)
	return setmetatable({ 
		pos = Vector(_x, _y),
		v = Vector(0, 0),
		f = Vector(0, 0),
		accel = Vector(0, 0),
		dir = Vector(0, 0),
		collider = Collider:addRectangle(_x, _y, 4, 4),
		target,
		-- mass = _mass,
		mass = grossMass,
		prevAccel = Vector(0, 0), -- for saving info
		power = ratedThrust,
		pVel = Vector(0, 0),
		fuel = grossMass - payloadMass - emptyMass,
		remainingBurnTime = burnTime,
		throttle = 1,
	}, Rocket_mt)
end

function Rocket:update(dt)
	self:move(dt)
	local airbrakeHack
	if airbrake then
		airbrakeHack = 1.2
	else
		airbrakeHack = 0
	end
	self.remainingBurnTime = self.fuel / (flowRate * numberOfEngines * (self.throttle + airbrakeHack)) -- this doesnt currently account for airbrake fuel use (because it's using throttle to calculate)
end

function Rocket:move(dt)
	self:calculateDirectionToTarget()
	if self.fuel > 0 then
		self:impulse(self.throttle, dt)
	end
	self.accel = self.f / self.mass
	self.prevAccel = self.accel
	self.v = self.v + self.accel * dt
	self.pos = self.pos + self.v * dt / meterToPixelRatio

	self.collider:moveTo(self.pos.x, self.pos.y)

	self.f = Vector(0, 0)
	-- self.accel = Vector(0, 0)
end

function Rocket:impulse(throttle, dt, airbrake)
	airbrake = airbrake or false
	local fuelUse = flowRate * dt * throttle * numberOfEngines
	self.fuel = self.fuel - fuelUse
	self.mass = self.mass - fuelUse
	if airbrake then
		self.f = self.f + self.v:normalized() * self.power * throttle * -1
	else
		self.f = self.f + self.dir * self.power * throttle
	end

end

function Rocket:stop()

end

function Rocket:airbrake(dt)
	self:impulse(1.2, dt, true)
end

function Rocket:draw()
	love.graphics.setColor(255, 132, 121, 255)
	love.graphics.circle('fill', self.pos.x, self.pos.y, 1) -- body

	love.graphics.setColor(0, 255, 125, 155)
	love.graphics.line(self.pos.x, self.pos.y, self.pos.x + self.v.x / meterToPixelRatio, self.pos.y + self.v.y / meterToPixelRatio) -- velocity
	love.graphics.circle('fill', self.pos.x + self.v.x / meterToPixelRatio, self.pos.y + self.v.y / meterToPixelRatio, 1, 32)

	love.graphics.setColor(255, 0, 255, 155)
	love.graphics.line(self.pos.x, self.pos.y, self.pos.x + self.accel.x / meterToPixelRatio * 10, self.pos.y + self.accel.y / meterToPixelRatio * 10) -- accel
	love.graphics.circle('line', self.pos.x + self.accel.x / meterToPixelRatio * 10, self.pos.y + self.accel.y / meterToPixelRatio * 10, 1, 32)

	-- if target then
	love.graphics.setColor(255, 255, 255, 155)
	love.graphics.circle('fill', self.target.x, self.target.y, 40, 16)
	-- end
end

function Rocket:setTarget(location)
	self.target = location
end

function Rocket:calculateDirectionToTarget()
	local t = Vector(self.target.x, self.target.y)
	local temp = t - self.pos
	self.dir = temp:normalized()
	-- print('rocket-target vector ' .. self.dir.x, self.dir.y)
end

return rocket