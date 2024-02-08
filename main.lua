math = require("math")

-- Window specs
window_width, window_height = love.window.getMode()

-- Create a little circle
local bead = {
	x = window_width / 2,
	y = 0,
	speed = { x = 0, y = 200 },
	radius = 30,
}

local peg = {
	x = window_width / 2,
	y = window_height * 2 / 3,
	radius = 30,
}

local gravity = 150

function love.update(dt)
	bead.speed.y = bead.speed.y + gravity * dt
	-- bead.speed.x = bead.speed.x + bead.acceleration.x

	bead.y = bead.y + bead.speed.y * dt
	-- bead.x = bead.x + bead.speed.x * dt

	if bead.y > window_height then
		bead.y = 0
	end

	if bead.y + bead.radius >= peg.y - peg.radius then
		bead.y = peg.y - peg.radius - bead.radius
		bead.speed.y = -bead.speed.y * 0.8
	end
end

function love.draw()
	love.graphics.setColor(1, 0, 0)
	love.graphics.circle("fill", bead.x, bead.y, bead.radius)
	love.graphics.setColor(1, 1, 1)
	love.graphics.circle("fill", peg.x, peg.y, peg.radius)
end
