math = require("math")

-- Window specs
window_width, window_height = love.window.getMode()

-- Create a little circle
local bead = {
	x = window_width * 0.2,
	y = 0,
	speed = { x = 200, y = 200 },
	radius = 30,
	angle = 0,
	angle_sign = 1,
	image = nil,
}

local peg = {
	x = window_width / 2,
	y = window_height * 2 / 3,
	radius = 30,
}

local gravity = 150

-- Diamonds parameters
local diamonds = {}
local max_diamonds = 5

function love.load()
	bead.image = love.graphics.newImage("bead.png")
end

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
		bead.angle_sign = side
	end
	-- if bead.y + bead.radius >= peg.y - peg.radius then
	-- end

	-- Update rotation angle based on movement
	bead.angle = bead.angle + 1.8 * bead.angle_sign * dt
	-- Update diamonds
	for i = #diamonds, 1, -1 do
		diamonds[i].timer = diamonds[i].timer - dt
		if diamonds[i].timer <= 0 then
			table.remove(diamonds, i)
		else
			diamonds[i].size = diamonds[i].size + (diamonds[i].max_size - diamonds[i].size) * dt * 5
		end
	end

	if #diamonds < max_diamonds and math.random() < 0.02 then
		local diamond = {
			x = math.random(window_width),
			y = math.random(window_height),
			size = 0,
			max_size = math.random(5, 15),
			timer = math.random(0.5, 1),
		}
		table.insert(diamonds, diamond)
	end
end

function love.draw()
	-- Draw background
	love.graphics.setBackgroundColor(0, 0, 0.3) -- Dark blue background

	-- Calculate the offset for the camera effect
	local camera_offset_x = window_width / 2 - bead.x
	local camera_offset_y = window_height / 2 - bead.y

	-- Translate the coordinate system to give the camera effect
	love.graphics.translate(camera_offset_x, camera_offset_y)

	-- Draw the bead image with rotation and scaling
	local scale = bead.radius * 2 / bead.image:getWidth() -- Scale relative to the radius of the bead
	love.graphics.draw(bead.image, bead.x, bead.y, bead.angle, scale, scale, bead.image:getWidth() / 2,
		bead.image:getHeight() / 2)

	-- Draw peg relative to the camera
	love.graphics.setColor(0.3, 0.3, 0.3)
	love.graphics.circle("fill", peg.x, peg.y, peg.radius)

	-- Draw diamonds
	love.graphics.setColor(1, 1, 0, 0.5) -- Yellow
	for _, diamond in ipairs(diamonds) do
		local size = diamond.size
		love.graphics.polygon("fill", diamond.x, diamond.y - size, diamond.x - size, diamond.y, diamond.x,
			diamond.y + size, diamond.x + size, diamond.y)
	end

	-- Reset the translation
	love.graphics.translate(-camera_offset_x, -camera_offset_y)
end
