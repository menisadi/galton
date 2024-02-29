math = require("math")

-- Window specs
WindowWidth, WindowHeight = love.window.getMode()

local moveDirection = 2 * math.random(2) - 3
local levels = 2
local reacedGround = false

-- Create a little circle
local bead = {
	x = WindowWidth * 0.2,
	y = 0,
	speed = { x = 200, y = 200 },
	radius = 30,
	angle = 0,
	angleSign = 1,
	image = nil,
}

local peg = {
	x = WindowWidth / 2,
	y = WindowHeight * 2 / 3,
	radius = 30,
}

-- Add a variable to keep track of the arc angle offset
local arcOffset = math.pi * 1.75

local gravity = 150

-- Diamonds parameters
local diamonds = {}
local maxDiamonds = 5

local ground = {
	x = WindowWidth / 2,
	y = WindowHeight * 0.95,
	widtch = WindowWidth * 0.80,
	height = 20
}

function love.load()
	bead.image = love.graphics.newImage("bead.png")
end

function love.update(dt)
	bead.speed.y = bead.speed.y + gravity * dt
	-- bead.speed.x = bead.speed.x + bead.acceleration.x

	bead.y = bead.y + bead.speed.y * dt
	bead.x = bead.x + bead.speed.x * dt

	-- bead got to the bottom of the screen -> appear at the top
	if bead.y > WindowHeight then
		levels = levels - 1
		bead.y = 0
		bead.speed.y = 200
		if bead.x >= WindowWidth / 2 then
			bead.x = WindowWidth * 0.2
			bead.speed.x = 200
		else
			bead.x = WindowWidth * (1 - 0.2)
			bead.speed.x = -200
		end
	end

	if levels == 0 then
		reacedGround = true
	end

	if reacedGround then
		if bead.y + bead.radius >= ground.y - ground.height / 2 then
			gravity = 0
			bead.speed.x = 0
			bead.speed.y = 0
		end
	end

	local function dist(p1, p2)
		local distSquare = math.pow(p1.x - p2.x, 2) + math.pow(p1.y - p2.y, 2)
		return math.sqrt(distSquare)
	end

	-- Update the arc offset based on user input
	if love.keyboard.isDown("right") then
		arcOffset = math.min(math.pi * 2, (arcOffset + 0.2))
		moveDirection = 1
	elseif love.keyboard.isDown("left") then
		arcOffset = math.max(math.pi * 1.5, (arcOffset - 0.2))
		moveDirection = -1
	end

	-- colision -> bounce
	if dist(bead, peg) <= bead.radius + peg.radius then
		if not reacedGround then
			bead.y = peg.y - peg.radius - bead.radius
			-- local side = 2 * math.random(2) - 3
			local side = moveDirection
			bead.speed.x = bead.speed.y * 0.4 * side
			bead.speed.y = -bead.speed.y * 0.4
			bead.angleSign = side
		end
	end
	-- if bead.y + bead.radius >= peg.y - peg.radius then
	-- end

	-- Update rotation angle based on movement
	if not reacedGround then
		bead.angle = bead.angle + 1.8 * bead.angleSign * dt
	end

	-- Update diamonds
	for i = #diamonds, 1, -1 do
		diamonds[i].timer = diamonds[i].timer - dt
		if diamonds[i].timer <= 0 then
			table.remove(diamonds, i)
		else
			diamonds[i].size = diamonds[i].size + (diamonds[i].maxSize - diamonds[i].size) * dt * 5
		end
	end

	if #diamonds < maxDiamonds and math.random() < 0.02 then
		local diamond = {
			x = math.random(WindowWidth),
			y = math.random(WindowHeight),
			size = 0,
			maxSize = math.random(5, 15),
			timer = math.random(0.5, 1),
		}
		table.insert(diamonds, diamond)
	end
end

function love.draw()
	-- Draw background
	love.graphics.setBackgroundColor(0.05, 0, 0.2) -- Dark blue background

	-- Calculate the offset for the camera effect
	local camera_offset_x = WindowWidth / 2 - bead.x
	local camera_offset_y = WindowHeight / 2 - bead.y
	if reacedGround and bead.y >= WindowHeight / 2 then
		camera_offset_x = 0
		camera_offset_y = 0
	end

	-- Translate the coordinate system to give the camera effect
	love.graphics.translate(camera_offset_x, camera_offset_y)

	-- Draw the bead image with rotation and scaling
	love.graphics.setColor(1, 1, 1, 1)
	local scale = bead.radius * 2 / bead.image:getWidth() -- Scale relative to the radius of the bead
	love.graphics.draw(bead.image, bead.x, bead.y, bead.angle, scale, scale, bead.image:getWidth() / 2,
		bead.image:getHeight() / 2)

	if not reacedGround then
		-- Draw peg relative to the camera
		love.graphics.setColor(0.3, 0.3, 0.3)
		love.graphics.circle("fill", peg.x, peg.y, peg.radius)

		-- Draw the dark orange arc on the peg's circumference
		love.graphics.setColor(0.7, 0.3, 0, 0.8) -- Dark orange
		local arcWidth = 5
		love.graphics.setLineWidth(arcWidth)
		local arcRadius = peg.radius - arcWidth
		local arcStart = -math.pi / 2 + arcOffset
		local arcEnd = arcStart + math.pi / 2
		love.graphics.arc("line", "open", peg.x, peg.y, arcRadius, arcStart, arcEnd)
	else
		love.graphics.setColor(1, 1, 1)
		love.graphics.rectangle("fill", WindowWidth * 0.1, WindowHeight * 0.95, ground.widtch, ground.height)
	end

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
