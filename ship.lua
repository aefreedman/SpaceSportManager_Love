local Ship = {}
local vector = require 'lib/HardonCollider/vector-light'

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

return Ship