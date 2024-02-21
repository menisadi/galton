math = require("math")

-- Window specs
window_width, window_height = love.window.getMode()

-- Create a little circle
local bead = {
	x = window_width * 0.2,
	y = 0,
	speed = { x = 200, y = 200 },
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
	bead.x = bead.x + bead.speed.x * dt

	-- bead got to the bottom of the screen -> appear at the top
	if bead.y > window_height then
		bead.y = 0
		bead.speed.y = 200
		if bead.x >= window_width / 2 then
			bead.x = window_width * 0.2
			bead.speed.x = 200
		else
			bead.x = window_width * (1 - 0.2)
			bead.speed.x = -200
		end
	end

	local function dist(p1, p2)
		local dist_square = math.pow(p1.x - p2.x, 2) + math.pow(p1.y - p2.y, 2)
		return math.sqrt(dist_square)
	end

	-- colision -> bounce
	if dist(bead, peg) <= bead.radius + peg.radius then
		bead.y = peg.y - peg.radius - bead.radius
		local side = 2 * math.random(2) - 3
		bead.speed.x = bead.speed.y * 0.4 * side
		bead.speed.y = -bead.speed.y * 0.4
	end
	-- if bead.y + bead.radius >= peg.y - peg.radius then
	-- end
end

function love.draw()
	love.graphics.setColor(1, 0, 0)
	love.graphics.circle("fill", bead.x, bead.y, bead.radius)
	love.graphics.setColor(1, 1, 1)
	love.graphics.circle("fill", peg.x, peg.y, peg.radius)
end
