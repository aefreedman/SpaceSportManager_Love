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

local ship = {}
local vector = require 'lib/HardonCollider/vector-light'
local tween = require 'lib.tween.tween'
-- local xVelTween = tween.new(1, Shi )

local Ship = {}
local Ship_mt = {__index = Ship}

-- Public interface

function ship.new(_x, _y, _mass)
	return setmetatable({ 
		x = _x,
		y = _y,
		xVel = 0,
		yVel = 0,
		xForce = 0,
		yForce = 0,
		xAcc = 0,
		yAcc = 0,
		dx = 0,
		dy = 0, 
		collider = Collider:addRectangle(_x, _y, 4, 4),
		target,
		mass = _mass,
		power = 100000,
		prevXVel,
		prevYVel
	}, Ship_mt)
end

function Ship:move(dt)
	self:impulse(1.0)
	self.xAcc = (self.xForce / self.mass) * dt
	self.yAcc = (self.yForce / self.mass) * dt
	self.xVel = self.xAcc * dt
	self.yVel = self.yAcc * dt
	self.x = self.x + self.xVel * dt
	self.y = self.y + self.yVel * dt
	self.collider:moveTo(self.x, self.y)

	-- print (vector.len(self.xForce, self.yForce))
	-- print (vector.len(self.xAcc, self.yAcc))
	print (vector.len(self.xVel, self.yVel))
	-- print (self.xVel .. ' ' .. self.yVel)

	self.xForce = 0
	self.yForce = 0
	-- self.xAcc = 0
	-- self.yAcc = 0

end

function Ship:impulse(percentageOfThrust)
	self.xForce = self.xForce + (self.dx * self.power * percentageOfThrust)
	self.yForce = self.yForce + (self.dy * self.power * percentageOfThrust)
	-- print(self.xForce .. ' ' .. self.yForce)
end

function Ship:stop()
	if self.xVel == 0 then
		if self.yVel == 0 then
			return
		end
	end
	self.xVel = 0
	self.yVel = 0
	self.xForce = 0
	self.yForce = 0
	self.xAcc = 0
	self.yAcc = 0
	print('stopping')
end

function Ship:draw()
	love.graphics.setColor(255, 132, 121, 255)
	love.graphics.circle('fill', self.x, self.y, 4)
	love.graphics.setColor(0, 255, 125, 155)
	love.graphics.line(self.x, self.y, self.x + self.xVel, self.y + self.yVel)
	love.graphics.setColor(255, 0, 0, 155)
	love.graphics.line(self.x, self.y, self.x + self.xAcc, self.y + self.yAcc)
	-- love.graphics.line(self.x, self.y, self.x + self.xVel, self.y + self.yVel)
	love.graphics.circle('line', self.x + self.xVel, self.y + self.yVel, 1, 8)
	if target then
		love.graphics.circle('line', self.target.x, self.target.y, self.target.r * 2, 16)
	end
end

function Ship:setTarget(location)
	self.target = location
end

function Ship:calculateDirectionToTarget()
	local _dx, _dy = vector.normalize(vector.sub(self.target.x, self.target.y, self.x, self.y))
	self.dx = _dx
	self.dy = _dy
	print('ship-target vector ' .. self.dx, self.dy)
end

return ship